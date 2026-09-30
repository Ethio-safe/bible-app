//go:build ignore
// +build ignore

package memory
package memory

import (
	"sync"

	"github.com/melion/fullstack-bible/backend/internal/domain"
)

type Repository struct {

















}	}		positions:  map[string]map[string]domain.ReadingPosition{},		bookmarks:  map[string]map[string]domain.Bookmark{},		highlights: map[string]map[string]domain.Highlight{},		notes:      map[string]map[string]domain.Note{},		users:      map[string]domain.User{},	return &Repository{func New() *Repository {}	positions map[string]map[string]domain.ReadingPosition	bookmarks map[string]map[string]domain.Bookmark	highlights map[string]map[string]domain.Highlight	notes     map[string]map[string]domain.Note	users     map[string]domain.User	mu        sync.Mutex