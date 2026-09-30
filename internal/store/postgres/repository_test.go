package postgres

import (
	"context"
	"errors"
	"os"
	"testing"
	"time"

	"github.com/google/uuid"

	"github.com/melion/fullstack-bible/backend/internal/domain"
	"github.com/melion/fullstack-bible/backend/internal/service"
)

func TestRepositoryPersistenceAndSync(t *testing.T) {
	url := os.Getenv("TEST_DATABASE_URL")
	if url == "" {
		t.Skip("set TEST_DATABASE_URL to an isolated PostgreSQL database")
	}
	ctx := context.Background()
	repo, err := Open(ctx, url)
	if err != nil {
		t.Fatal(err)
	}
	defer func() { repo.Close() }()

	id := uuid.NewString()
	email := id + "@example.invalid"
	now := time.Now().UTC().Truncate(time.Microsecond)
	user := domain.User{ID: id, Email: email, DisplayName: "Test",
		PasswordHash: "hash", CreatedAt: now, UpdatedAt: now}
	if _, err := repo.CreateUser(user); err != nil {
		t.Fatal(err)
	}
	if _, err := repo.CreateUser(domain.User{ID: uuid.NewString(), Email: email}); !errors.Is(err, service.ErrEmailTaken) {
		t.Fatalf("duplicate email: got %v", err)
	}
	note := domain.Note{ID: uuid.NewString(), UserID: "forged", Body: "100% hello_world",
		CreatedAt: now, UpdatedAt: now}
	push := domain.SyncPushRequest{Notes: []domain.Note{note}}
	push.Highlights = []domain.Highlight{{
		ID: uuid.NewString(), UserID: "forged", Color: 2,
		CreatedAt: now, UpdatedAt: now,
	}}
	push.Bookmarks = []domain.Bookmark{{
		ID: uuid.NewString(), UserID: "forged",
		CreatedAt: now, UpdatedAt: now,
	}}
	push.ReadingPositions = []domain.ReadingPosition{{
		Translation: "KJV", UserID: "forged", UpdatedAt: now, BookID: 1,
	}}
	snap, err := repo.ApplySync(id, push)
	if err != nil {
		t.Fatal(err)
	}
	if len(snap.Notes) != 1 || snap.Notes[0].UserID != id ||
		len(snap.Highlights) != 1 || snap.Highlights[0].UserID != id ||
		len(snap.Bookmarks) != 1 || snap.Bookmarks[0].UserID != id ||
		len(snap.ReadingPositions) != 1 || snap.ReadingPositions[0].UserID != id {
		t.Fatalf("wrong synced snapshot: %+v", snap)
	}
	if _, err := repo.ApplySync("missing-user", push); !errors.Is(err, service.ErrNotFound) {
		t.Fatalf("unknown user: got %v", err)
	}
	// The entire batch rolls back on invalid data, not just its last item.
	_, err = repo.ApplySync(id, domain.SyncPushRequest{Notes: []domain.Note{
		{ID: uuid.NewString(), UpdatedAt: now, Body: "should roll back"},
		{ID: "", UpdatedAt: now},
	}})
	if err == nil {
		t.Fatal("invalid sync accepted")
	}
	repo.Close()
	repo, err = Open(ctx, url)
	if err != nil {
		t.Fatal(err)
	}
	snap, err = repo.Snapshot(id)
	if err != nil || len(snap.Notes) != 1 || len(snap.Highlights) != 1 ||
		len(snap.Bookmarks) != 1 || len(snap.ReadingPositions) != 1 {
		t.Fatalf("not persisted or batch not rolled back: %+v, %v", snap, err)
	}
	older := note
	older.Body = "stale"
	older.UpdatedAt = now.Add(-time.Minute)
	if got, err := repo.UpsertNote(id, older); err != nil || got.Body != note.Body {
		t.Fatalf("stale update overwrote note: %+v, %v", got, err)
	}
	notes, err := repo.SearchNotes(id, "% hello_", 20)
	if err != nil || len(notes) != 1 {
		t.Fatalf("literal search: %+v, %v", notes, err)
	}
	if err := repo.DeleteNote(id, note.ID); err != nil {
		t.Fatal(err)
	}
	snap, err = repo.Snapshot(id)
	if err != nil || len(snap.Notes) != 1 || snap.Notes[0].DeletedAt == nil {
		t.Fatalf("tombstone missing: %+v, %v", snap, err)
	}
	notes, err = repo.SearchNotes(id, "hello", 20)
	if err != nil || len(notes) != 0 {
		t.Fatalf("deleted note visible in search: %+v, %v", notes, err)
	}
}
