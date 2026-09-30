//go:build ignore
// +build ignore

package filestore

import (
	"sort"
	"strings"
	"time"

	"github.com/melion/fullstack-bible/backend/internal/domain"
	"github.com/melion/fullstack-bible/backend/internal/service"
)

func (r *Repository) ApplySync(userID string, push domain.SyncPushRequest) (domain.SyncSnapshot, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	user, ok := r.data.Users[userID]
	if !ok {
		return domain.SyncSnapshot{}, service.ErrNotFound
	}
	for _, item := range push.Notes {
		r.upsertNoteLocked(userID, item)
	}
	for _, item := range push.Highlights {
		r.upsertHighlightLocked(userID, item)
	}
	for _, item := range push.Bookmarks {
		r.upsertBookmarkLocked(userID, item)
	}
	for _, item := range push.ReadingPositions {
		r.upsertPositionLocked(userID, item)
	}
	if err := r.saveLocked(); err != nil {
		return domain.SyncSnapshot{}, err
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

func (r *Repository) UpsertNote(userID string, note domain.Note) (domain.Note, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	out := r.upsertNoteLocked(userID, note)
	return out, r.saveLocked()
}

func (r *Repository) DeleteNote(userID, id string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	item, ok := ensureBucket(r.data.Notes, userID)[id]
	if !ok {
		return service.ErrNotFound
	}
	now := time.Now().UTC()
	item.UpdatedAt = now
	item.DeletedAt = &now
	item.UserID = userID
	ensureBucket(r.data.Notes, userID)[id] = item
	return r.saveLocked()
}

func (r *Repository) UpsertHighlight(userID string, item domain.Highlight) (domain.Highlight, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	out := r.upsertHighlightLocked(userID, item)
	return out, r.saveLocked()
}

func (r *Repository) DeleteHighlight(userID, id string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	item, ok := ensureBucket(r.data.Highlights, userID)[id]
	if !ok {
		return service.ErrNotFound
	}
	now := time.Now().UTC()
	item.UpdatedAt = now
	item.DeletedAt = &now
	item.UserID = userID
	ensureBucket(r.data.Highlights, userID)[id] = item
	return r.saveLocked()
}

func (r *Repository) UpsertBookmark(userID string, item domain.Bookmark) (domain.Bookmark, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	out := r.upsertBookmarkLocked(userID, item)
	return out, r.saveLocked()
}

func (r *Repository) DeleteBookmark(userID, id string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	item, ok := ensureBucket(r.data.Bookmarks, userID)[id]
	if !ok {
		return service.ErrNotFound
	}
	now := time.Now().UTC()
	item.UpdatedAt = now
	item.DeletedAt = &now
	item.UserID = userID
	ensureBucket(r.data.Bookmarks, userID)[id] = item
	return r.saveLocked()
}

func (r *Repository) UpsertReadingPosition(userID string, item domain.ReadingPosition) (domain.ReadingPosition, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	out := r.upsertPositionLocked(userID, item)
	return out, r.saveLocked()
}

func (r *Repository) SearchNotes(userID, query string, limit int) ([]domain.Note, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	query = strings.ToLower(strings.TrimSpace(query))
	if query == "" {
		return []domain.Note{}, nil
	}
	out := make([]domain.Note, 0)
	for _, item := range ensureBucket(r.data.Notes, userID) {
		if item.DeletedAt == nil && strings.Contains(strings.ToLower(item.Body), query) {
			out = append(out, item)
		}
	}
	sort.Slice(out, func(i, j int) bool { return out[i].UpdatedAt.After(out[j].UpdatedAt) })
	if limit > 0 && len(out) > limit {
		out = out[:limit]
	}
	return out, nil
}
