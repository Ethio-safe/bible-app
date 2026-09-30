//go:build ignore
// +build ignore

package filestore

import (
	"sort"

	"github.com/melion/fullstack-bible/backend/internal/domain"
)

func ensureBucket[T any](items map[string]map[string]T, userID string) map[string]T {
	bucket, ok := items[userID]
	if !ok {
		bucket = map[string]T{}
		items[userID] = bucket
	}
	return bucket
}

func (r *Repository) upsertNoteLocked(userID string, item domain.Note) domain.Note {
	bucket := ensureBucket(r.data.Notes, userID)
	if current, ok := bucket[item.ID]; ok && current.UpdatedAt.After(item.UpdatedAt) {
		return current
	}
	item.UserID = userID
	bucket[item.ID] = item
	return item
}

func (r *Repository) upsertHighlightLocked(userID string, item domain.Highlight) domain.Highlight {
	bucket := ensureBucket(r.data.Highlights, userID)
	if current, ok := bucket[item.ID]; ok && current.UpdatedAt.After(item.UpdatedAt) {
		return current
	}
	item.UserID = userID
	bucket[item.ID] = item
	return item
}

func (r *Repository) upsertBookmarkLocked(userID string, item domain.Bookmark) domain.Bookmark {
	bucket := ensureBucket(r.data.Bookmarks, userID)
	if current, ok := bucket[item.ID]; ok && current.UpdatedAt.After(item.UpdatedAt) {
		return current
	}
	item.UserID = userID
	bucket[item.ID] = item
	return item
}

func (r *Repository) upsertPositionLocked(userID string, item domain.ReadingPosition) domain.ReadingPosition {
	bucket := ensureBucket(r.data.ReadingPositions, userID)
	if current, ok := bucket[item.Translation]; ok && current.UpdatedAt.After(item.UpdatedAt) {
		return current
	}
	item.UserID = userID
	bucket[item.Translation] = item
	return item
}

func sortedNotes(bucket map[string]domain.Note) []domain.Note {
	out := make([]domain.Note, 0, len(bucket))
	for _, item := range bucket {
		out = append(out, item)
	}
	sort.Slice(out, func(i, j int) bool { return out[i].UpdatedAt.After(out[j].UpdatedAt) })
	return out
}

func sortedHighlights(bucket map[string]domain.Highlight) []domain.Highlight {
	out := make([]domain.Highlight, 0, len(bucket))
	for _, item := range bucket {
		out = append(out, item)
	}
	sort.Slice(out, func(i, j int) bool { return out[i].UpdatedAt.After(out[j].UpdatedAt) })
	return out
}

func sortedBookmarks(bucket map[string]domain.Bookmark) []domain.Bookmark {
	out := make([]domain.Bookmark, 0, len(bucket))
	for _, item := range bucket {
		out = append(out, item)
	}
	sort.Slice(out, func(i, j int) bool { return out[i].UpdatedAt.After(out[j].UpdatedAt) })
	return out
}

func sortedPositions(bucket map[string]domain.ReadingPosition) []domain.ReadingPosition {
	out := make([]domain.ReadingPosition, 0, len(bucket))
	for _, item := range bucket {
		out = append(out, item)
	}
	sort.Slice(out, func(i, j int) bool { return out[i].UpdatedAt.After(out[j].UpdatedAt) })
	return out
}
