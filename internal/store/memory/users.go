package memory

import (
	"strings"
	"time"

	"github.com/melion/fullstack-bible/backend/internal/domain"
	"github.com/melion/fullstack-bible/backend/internal/service"
)

func (r *Repository) CreateUser(user domain.User) (domain.User, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	if _, ok := findUserByEmail(r.users, user.Email); ok {
		return domain.User{}, service.ErrEmailTaken
	}
	r.users[user.ID] = user
	return user, nil
}

func (r *Repository) FindUserByEmail(email string) (*domain.User, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	user, ok := findUserByEmail(r.users, strings.ToLower(strings.TrimSpace(email)))
	if !ok {
		return nil, service.ErrNotFound
	}
	copy := user
	return &copy, nil
}

func (r *Repository) GetUserByID(id string) (*domain.User, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	user, ok := r.users[id]
	if !ok {
		return nil, service.ErrNotFound
	}
	copy := user
	return &copy, nil
}

func (r *Repository) Snapshot(userID string) (domain.SyncSnapshot, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	user, ok := r.users[userID]
	if !ok {
		return domain.SyncSnapshot{}, service.ErrNotFound
	}
	notes := make([]domain.Note, 0, len(ensureBucket(r.notes, userID)))
	for _, item := range ensureBucket(r.notes, userID) { notes = append(notes, item) }
	highlights := make([]domain.Highlight, 0, len(ensureBucket(r.highlights, userID)))
	for _, item := range ensureBucket(r.highlights, userID) { highlights = append(highlights, item) }
	bookmarks := make([]domain.Bookmark, 0, len(ensureBucket(r.bookmarks, userID)))
	for _, item := range ensureBucket(r.bookmarks, userID) { bookmarks = append(bookmarks, item) }
	positions := make([]domain.ReadingPosition, 0, len(ensureBucket(r.positions, userID)))
	for _, item := range ensureBucket(r.positions, userID) { positions = append(positions, item) }
	sortNotes(notes)
	sortHighlights(highlights)
	sortBookmarks(bookmarks)
	sortPositions(positions)
	return domain.SyncSnapshot{User: user, Notes: notes, Highlights: highlights, Bookmarks: bookmarks, ReadingPositions: positions, ServerTime: time.Now().UTC()}, nil
}
