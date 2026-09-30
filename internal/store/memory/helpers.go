package memory

import (
	"sort"
	"strings"

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

func findUserByEmail(users map[string]domain.User, email string) (domain.User, bool) {
	for _, user := range users {
		if strings.EqualFold(user.Email, email) {
			return user, true
		}
	}
	return domain.User{}, false
}

func sortNotes(items []domain.Note) {
	sort.Slice(items, func(i, j int) bool { return items[i].UpdatedAt.After(items[j].UpdatedAt) })
}

func sortHighlights(items []domain.Highlight) {
	sort.Slice(items, func(i, j int) bool { return items[i].UpdatedAt.After(items[j].UpdatedAt) })
}

func sortBookmarks(items []domain.Bookmark) {
	sort.Slice(items, func(i, j int) bool { return items[i].UpdatedAt.After(items[j].UpdatedAt) })
}

func sortPositions(items []domain.ReadingPosition) {
	sort.Slice(items, func(i, j int) bool { return items[i].UpdatedAt.After(items[j].UpdatedAt) })
}
