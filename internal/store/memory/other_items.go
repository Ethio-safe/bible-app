package memory

import (
	"time"

	"github.com/melion/fullstack-bible/backend/internal/domain"
	"github.com/melion/fullstack-bible/backend/internal/service"
)

func (r *Repository) UpsertHighlight(userID string, item domain.Highlight) (domain.Highlight, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	bucket := ensureBucket(r.highlights, userID)
	if current, ok := bucket[item.ID]; ok && current.UpdatedAt.After(item.UpdatedAt) { return current, nil }
	item.UserID = userID
	bucket[item.ID] = item
	return item, nil
}

func (r *Repository) DeleteHighlight(userID, id string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	item, ok := ensureBucket(r.highlights, userID)[id]
	if !ok { return service.ErrNotFound }
	now := time.Now().UTC(); item.UserID = userID; item.UpdatedAt = now; item.DeletedAt = &now
	ensureBucket(r.highlights, userID)[id] = item
	return nil
}

func (r *Repository) UpsertBookmark(userID string, item domain.Bookmark) (domain.Bookmark, error) {
	r.mu.Lock(); defer r.mu.Unlock()
	bucket := ensureBucket(r.bookmarks, userID)
	if current, ok := bucket[item.ID]; ok && current.UpdatedAt.After(item.UpdatedAt) { return current, nil }
	item.UserID = userID
	bucket[item.ID] = item
	return item, nil
}

func (r *Repository) DeleteBookmark(userID, id string) error {
	r.mu.Lock(); defer r.mu.Unlock()
	item, ok := ensureBucket(r.bookmarks, userID)[id]
	if !ok { return service.ErrNotFound }
	now := time.Now().UTC(); item.UserID = userID; item.UpdatedAt = now; item.DeletedAt = &now
	ensureBucket(r.bookmarks, userID)[id] = item
	return nil
}

func (r *Repository) UpsertReadingPosition(userID string, item domain.ReadingPosition) (domain.ReadingPosition, error) {
	r.mu.Lock(); defer r.mu.Unlock()
	bucket := ensureBucket(r.positions, userID)
	if current, ok := bucket[item.Translation]; ok && current.UpdatedAt.After(item.UpdatedAt) { return current, nil }
	item.UserID = userID
	bucket[item.Translation] = item
	return item, nil
}

func (r *Repository) ApplySync(userID string, push domain.SyncPushRequest) (domain.SyncSnapshot, error) {
	for _, item := range push.Notes { _, _ = r.UpsertNote(userID, item) }
	for _, item := range push.Highlights { _, _ = r.UpsertHighlight(userID, item) }
	for _, item := range push.Bookmarks { _, _ = r.UpsertBookmark(userID, item) }
	for _, item := range push.ReadingPositions { _, _ = r.UpsertReadingPosition(userID, item) }
	return r.Snapshot(userID)
}
