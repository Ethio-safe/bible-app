//go:build ignore
// +build ignore

package filestore

import (
	"strings"
	"time"

	"github.com/melion/fullstack-bible/backend/internal/domain"
	"github.com/melion/fullstack-bible/backend/internal/service"
)

func (r *Repository) CreateUser(user domain.User) (domain.User, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	if _, ok := r.findUserByEmailLocked(user.Email); ok {
		return domain.User{}, service.ErrEmailTaken
	}
	r.data.Users[user.ID] = user
	return user, r.saveLocked()
}

func (r *Repository) FindUserByEmail(email string) (*domain.User, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	user, ok := r.findUserByEmailLocked(strings.ToLower(strings.TrimSpace(email)))
	if !ok {
		return nil, service.ErrNotFound
	}
	copy := user
	return &copy, nil
}

func (r *Repository) GetUserByID(id string) (*domain.User, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	user, ok := r.data.Users[id]
	if !ok {
		return nil, service.ErrNotFound
	}
	copy := user
	return &copy, nil
}

func (r *Repository) Snapshot(userID string) (domain.SyncSnapshot, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	user, ok := r.data.Users[userID]
	if !ok {
		return domain.SyncSnapshot{}, service.ErrNotFound
	}
	return domain.SyncSnapshot{
		User:             user,
		Notes:            sortedNotes(ensureBucket(r.data.Notes, user.ID)),
		Highlights:       sortedHighlights(ensureBucket(r.data.Highlights, user.ID)),
		Bookmarks:        sortedBookmarks(ensureBucket(r.data.Bookmarks, user.ID)),
		ReadingPositions: sortedPositions(ensureBucket(r.data.ReadingPositions, user.ID)),
		ServerTime:       time.Now().UTC(),
	}, nil
}

func (r *Repository) findUserByEmailLocked(email string) (domain.User, bool) {
	for _, user := range r.data.Users {
		if strings.EqualFold(user.Email, email) {
			return user, true
		}
	}
	return domain.User{}, false
}
