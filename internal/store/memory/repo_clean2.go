package memory

import (
	"sync"

	"github.com/melion/fullstack-bible/backend/internal/domain"
)

type Repository struct {
	mu         sync.Mutex
	users      map[string]domain.User
	notes      map[string]map[string]domain.Note
	highlights map[string]map[string]domain.Highlight
	bookmarks  map[string]map[string]domain.Bookmark
	positions  map[string]map[string]domain.ReadingPosition
}

func New() *Repository {
	return &Repository{
		users:      map[string]domain.User{},
		notes:      map[string]map[string]domain.Note{},
		highlights: map[string]map[string]domain.Highlight{},
		bookmarks:  map[string]map[string]domain.Bookmark{},
		positions:  map[string]map[string]domain.ReadingPosition{},
	}
}
