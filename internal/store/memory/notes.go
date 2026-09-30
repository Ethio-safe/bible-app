package memory

import (
	"sort"
	"strings"
	"time"

	"github.com/melion/fullstack-bible/backend/internal/domain"
	"github.com/melion/fullstack-bible/backend/internal/service"
)

func (r *Repository) UpsertNote(userID string, note domain.Note) (domain.Note, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	bucket := ensureBucket(r.notes, userID)
	if current, ok := bucket[note.ID]; ok && current.UpdatedAt.After(note.UpdatedAt) {
		return current, nil
	}
	note.UserID = userID
	bucket[note.ID] = note
	return note, nil
}

func (r *Repository) DeleteNote(userID, id string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	item, ok := ensureBucket(r.notes, userID)[id]
	if !ok {
		return service.ErrNotFound
	}
	now := time.Now().UTC()
	item.UserID = userID
	item.UpdatedAt = now
	item.DeletedAt = &now
	ensureBucket(r.notes, userID)[id] = item
	return nil
}

func (r *Repository) SearchNotes(userID, query string, limit int) ([]domain.Note, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	query = strings.ToLower(strings.TrimSpace(query))
	out := make([]domain.Note, 0)
	for _, item := range ensureBucket(r.notes, userID) {
		if item.DeletedAt == nil && strings.Contains(strings.ToLower(item.Body), query) {
			out = append(out, item)
		}
	}
	sort.Slice(out, func(i, j int) bool { return out[i].UpdatedAt.After(out[j].UpdatedAt) })
	if limit > 0 && len(out) > limit { out = out[:limit] }
	return out, nil
}
