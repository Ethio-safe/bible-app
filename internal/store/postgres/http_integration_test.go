package postgres

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"

	"github.com/google/uuid"

	"github.com/melion/fullstack-bible/backend/internal/auth"
	"github.com/melion/fullstack-bible/backend/internal/config"
	"github.com/melion/fullstack-bible/backend/internal/httpapi"
	"github.com/melion/fullstack-bible/backend/internal/service"
)

func TestHTTPAfterRestart(t *testing.T) {
	url := os.Getenv("TEST_DATABASE_URL")
	if url == "" {
		t.Skip("set TEST_DATABASE_URL to an isolated PostgreSQL database")
	}
	open := func() (*Repository, http.Handler) {
		t.Helper()
		repo, err := Open(context.Background(), url)
		if err != nil {
			t.Fatal(err)
		}
		jwt := auth.NewManager("local-integration-test-secret", time.Hour)
		return repo, httpapi.NewRouter(config.Config{}, service.New(repo, jwt), jwt)
	}
	repo, router := open()
	email := uuid.NewString() + "@example.invalid"
	body, _ := json.Marshal(map[string]string{"email": email, "password": "test-password-123"})
	request := func(router http.Handler, method, path string, body []byte, token string) *httptest.ResponseRecorder {
		t.Helper()
		req := httptest.NewRequest(method, path, bytes.NewReader(body))
		if token != "" {
			req.Header.Set("Authorization", "Bearer "+token)
		}
		rec := httptest.NewRecorder()
		router.ServeHTTP(rec, req)
		return rec
	}
	rec := request(router, http.MethodPost, "/v1/auth/register", body, "")
	if rec.Code != http.StatusCreated {
		t.Fatalf("register: %d %s", rec.Code, rec.Body.String())
	}
	var account struct {
		Tokens struct {
			AccessToken string `json:"accessToken"`
		} `json:"tokens"`
	}
	if err := json.Unmarshal(rec.Body.Bytes(), &account); err != nil || account.Tokens.AccessToken == "" {
		t.Fatalf("tokens: %v %s", err, rec.Body.String())
	}
	token := account.Tokens.AccessToken
	repo.Close()
	repo, router = open()
	defer repo.Close()
	rec = request(router, http.MethodGet, "/healthz", nil, "")
	if rec.Code != http.StatusOK {
		t.Fatalf("health: %d %s", rec.Code, rec.Body.String())
	}
	rec = request(router, http.MethodPost, "/v1/auth/login", body, "")
	if rec.Code != http.StatusOK {
		t.Fatalf("login after restart: %d %s", rec.Code, rec.Body.String())
	}
	rec = request(router, http.MethodGet, "/v1/sync/bootstrap", nil, token)
	if rec.Code != http.StatusOK {
		t.Fatalf("bootstrap after restart: %d %s", rec.Code, rec.Body.String())
	}
	rec = request(router, http.MethodPost, "/v1/sync/push", []byte(`{"notes":[{"id":""}]}`), token)
	if rec.Code != http.StatusBadRequest {
		t.Fatalf("invalid sync: %d %s", rec.Code, rec.Body.String())
	}
}
