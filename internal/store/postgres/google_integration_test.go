package postgres

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"net/url"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/melion/fullstack-bible/backend/internal/auth"
	"github.com/melion/fullstack-bible/backend/internal/config"
	"github.com/melion/fullstack-bible/backend/internal/domain"
	"github.com/melion/fullstack-bible/backend/internal/httpapi"
	"github.com/melion/fullstack-bible/backend/internal/service"
)

type testGoogleVerifier struct {
	identity auth.GoogleIdentity
}

func (v testGoogleVerifier) Verify(_ context.Context, token string) (auth.GoogleIdentity, error) {
	if token != "verified" {
		return auth.GoogleIdentity{}, auth.ErrInvalidGoogleToken
	}
	return v.identity, nil
}

func TestGoogleHTTPPersistence(t *testing.T) {
	databaseURL := os.Getenv("TEST_DATABASE_URL")
	if databaseURL == "" {
		t.Skip("set TEST_DATABASE_URL to an isolated PostgreSQL database")
	}
	repo, err := Open(context.Background(), databaseURL)
	if err != nil {
		t.Fatal(err)
	}
	defer func() { repo.Close() }()
	manager := auth.NewManager("local-only-test-secret", time.Hour)
	svc := service.New(repo, manager)
	router := httpapi.NewRouter(config.Config{}, svc, manager)
	request := func(path string, value any, bearer string) *httptest.ResponseRecorder {
		t.Helper()
		data, err := json.Marshal(value)
		if err != nil {
			t.Fatal(err)
		}
		req := httptest.NewRequest(http.MethodPost, path, bytes.NewReader(data))
		if bearer != "" {
			req.Header.Set("Authorization", "Bearer "+bearer)
		}
		rec := httptest.NewRecorder()
		router.ServeHTTP(rec, req)
		return rec
	}
	google := func(token string) *httptest.ResponseRecorder {
		return request("/v1/auth/google", map[string]string{"idToken": token}, "")
	}
	if rec := google("verified"); rec.Code != http.StatusNotImplemented {
		t.Fatalf("unconfigured Google auth: %d %s", rec.Code, rec.Body.String())
	}
	email := uuid.NewString() + "@example.invalid"
	password := "account-password-123"
	rec := request("/v1/auth/register", map[string]string{
		"email": email, "password": password, "displayName": "Initial",
	}, "")
	if rec.Code != http.StatusCreated {
		t.Fatalf("register: %d %s", rec.Code, rec.Body.String())
	}
	var original struct {
		User domain.User `json:"user"`
	}
	if err := json.Unmarshal(rec.Body.Bytes(), &original); err != nil || original.User.PhotoURL != "" {
		t.Fatalf("register photoUrl: %s, %v", rec.Body.String(), err)
	}
	note, err := repo.UpsertNote(original.User.ID, domain.Note{
		ID: uuid.NewString(), Body: "before linking",
		CreatedAt: time.Now().UTC(), UpdatedAt: time.Now().UTC(),
	})
	if err != nil {
		t.Fatal(err)
	}
	svc.WithGoogleVerifier(testGoogleVerifier{auth.GoogleIdentity{
		Email: email, DisplayName: "Google Name", PhotoURL: "https://example.com/avatar.png",
	}})
	if rec := google("bad-token"); rec.Code != http.StatusUnauthorized {
		t.Fatalf("invalid ID token: %d %s", rec.Code, rec.Body.String())
	}
	rec = google("verified")
	if rec.Code != http.StatusOK {
		t.Fatalf("Google login: %d %s", rec.Code, rec.Body.String())
	}
	var linked struct {
		User   domain.User `json:"user"`
		Tokens struct {
			AccessToken string    `json:"accessToken"`
			ExpiresAt   time.Time `json:"expiresAt"`
		} `json:"tokens"`
	}
	if err := json.Unmarshal(rec.Body.Bytes(), &linked); err != nil {
		t.Fatal(err)
	}
	if linked.User.ID != original.User.ID || linked.User.PhotoURL != "https://example.com/avatar.png" ||
		linked.User.DisplayName != "Google Name" || linked.Tokens.AccessToken == "" ||
		linked.Tokens.ExpiresAt.Before(time.Now()) {
		t.Fatalf("linked identity: %+v", linked)
	}
	rec = request("/v1/auth/login", map[string]string{"email": email, "password": password}, "")
	if rec.Code != http.StatusOK {
		t.Fatalf("linked password login changed: %d %s", rec.Code, rec.Body.String())
	}
	repo.Close()
	repo, err = Open(context.Background(), databaseURL)
	if err != nil {
		t.Fatal(err)
	}
	svc = service.New(repo, manager).WithGoogleVerifier(testGoogleVerifier{auth.GoogleIdentity{
		Email: email, DisplayName: "Renamed", PhotoURL: "https://example.com/new.png",
	}})
	router = httpapi.NewRouter(config.Config{}, svc, manager)
	rec = google("verified")
	if rec.Code != http.StatusOK {
		t.Fatalf("Google login after reopening DB: %d %s", rec.Code, rec.Body.String())
	}
	var again struct {
		User domain.User `json:"user"`
	}
	if err := json.Unmarshal(rec.Body.Bytes(), &again); err != nil ||
		again.User.ID != original.User.ID || again.User.PhotoURL != "https://example.com/new.png" {
		t.Fatalf("profile not updated: %s, %v", rec.Body.String(), err)
	}
	req := httptest.NewRequest(http.MethodGet, "/v1/sync/bootstrap", nil)
	req.Header.Set("Authorization", "Bearer "+linked.Tokens.AccessToken)
	rec = httptest.NewRecorder()
	router.ServeHTTP(rec, req)
	if rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"photoUrl":"https://example.com/new.png"`) ||
		!strings.Contains(rec.Body.String(), `"id":"`+note.ID+`"`) {
		t.Fatalf("bootstrap missing photoUrl: %d %s", rec.Code, rec.Body.String())
	}
	otherEmail := uuid.NewString() + "@example.invalid"
	svc.WithGoogleVerifier(testGoogleVerifier{auth.GoogleIdentity{
		Email: otherEmail, DisplayName: "", PhotoURL: "",
	}})
	rec = google("verified")
	if rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"displayName":"`+otherEmail+`"`) {
		t.Fatalf("new Google account: %d %s", rec.Code, rec.Body.String())
	}
	rec = request("/v1/auth/login", map[string]string{"email": otherEmail, "password": password}, "")
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("Google-only account has usable password: %d %s", rec.Code, rec.Body.String())
	}
}

func TestPhotoURLMigration(t *testing.T) {
	databaseURL := os.Getenv("TEST_DATABASE_URL")
	if databaseURL == "" {
		t.Skip("set TEST_DATABASE_URL to an isolated PostgreSQL database")
	}
	ctx := context.Background()
	pool, err := pgxpool.New(ctx, databaseURL)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	schemaName := "google_upgrade_" + strings.ReplaceAll(uuid.NewString(), "-", "")
	if _, err := pool.Exec(ctx, `CREATE SCHEMA `+schemaName); err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() {
		_, err := pool.Exec(context.Background(), `DROP SCHEMA `+schemaName+` CASCADE`)
		if err != nil {
			t.Errorf("drop test schema: %v", err)
		}
	})
	_, err = pool.Exec(ctx, `CREATE TABLE `+schemaName+`.users (
		id text PRIMARY KEY, email text NOT NULL UNIQUE, display_name text NOT NULL,
		password_hash text NOT NULL, created_at timestamptz NOT NULL, updated_at timestamptz NOT NULL
	)`)
	if err != nil {
		t.Fatal(err)
	}
	id := uuid.NewString()
	email := uuid.NewString() + "@example.invalid"
	now := time.Now().UTC()
	_, err = pool.Exec(ctx, `INSERT INTO `+schemaName+`.users
		(id,email,display_name,password_hash,created_at,updated_at) VALUES ($1,$2,$3,$4,$5,$6)`,
		id, email, "Old", "hash", now, now)
	if err != nil {
		t.Fatal(err)
	}
	dsn, err := url.Parse(databaseURL)
	if err != nil {
		t.Fatal(err)
	}
	query := dsn.Query()
	query.Set("search_path", schemaName)
	dsn.RawQuery = query.Encode()
	repo, err := Open(ctx, dsn.String())
	if err != nil {
		t.Fatalf("upgrade old users table: %v", err)
	}
	defer repo.Close()
	user, err := repo.GetUserByID(id)
	if err != nil || user.ID != id || user.PhotoURL != "" {
		t.Fatalf("existing user after migration: %+v, %v", user, err)
	}
	updated, err := repo.UpsertGoogleUser(domain.User{
		ID: uuid.NewString(), Email: email, DisplayName: "New",
		PhotoURL: "https://example.com/avatar.png", PasswordHash: "not-saved",
		CreatedAt: now, UpdatedAt: now.Add(time.Minute),
	})
	if err != nil || updated.ID != id || updated.PhotoURL != "https://example.com/avatar.png" ||
		updated.PasswordHash != "hash" {
		t.Fatalf("migrated user/link: %+v, %v", updated, err)
	}
	if _, err := repo.FindUserByEmail(email); err != nil {
		t.Fatalf("existing user missing: %v", err)
	}
}
