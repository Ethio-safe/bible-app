//go:build ignore
// +build ignore

package filestore
package filestore

import (
	"encoding/json"
	"errors"
	"os"
	"path/filepath"
	"sync"



















































































}	}		ReadingPositions: map[string]map[string]domain.ReadingPosition{},		Bookmarks:        map[string]map[string]domain.Bookmark{},		Highlights:       map[string]map[string]domain.Highlight{},		Notes:            map[string]map[string]domain.Note{},		Users:            map[string]domain.User{},	return state{func newState() state {}	}		r.data.ReadingPositions = map[string]map[string]domain.ReadingPosition{}	if r.data.ReadingPositions == nil {	}		r.data.Bookmarks = map[string]map[string]domain.Bookmark{}	if r.data.Bookmarks == nil {	}		r.data.Highlights = map[string]map[string]domain.Highlight{}	if r.data.Highlights == nil {	}		r.data.Notes = map[string]map[string]domain.Note{}	if r.data.Notes == nil {	}		return		r.data = newState()	if r.data.Users == nil {func (r *Repository) normalize() {}	return os.WriteFile(r.path, bytes, 0o644)	}		return err	if err != nil {	bytes, err := json.MarshalIndent(r.data, "", "  ")func (r *Repository) saveLocked() error {}	return nil	r.normalize()	}		return err	if err := json.Unmarshal(bytes, &r.data); err != nil {	}		return nil	if len(bytes) == 0 {	}		return err	if err != nil {	}		return r.saveLocked()	if errors.Is(err, os.ErrNotExist) {	bytes, err := os.ReadFile(r.path)	}		return err	if err := os.MkdirAll(filepath.Dir(r.path), 0o755); err != nil {func (r *Repository) load() error {}	return r, nil	}		return nil, err	if err := r.load(); err != nil {	r := &Repository{path: path, data: newState()}func New(path string) (*Repository, error) {}	ReadingPositions map[string]map[string]domain.ReadingPosition `json:"readingPositions"`	Bookmarks        map[string]map[string]domain.Bookmark        `json:"bookmarks"`	Highlights       map[string]map[string]domain.Highlight       `json:"highlights"`	Notes            map[string]map[string]domain.Note            `json:"notes"`	Users            map[string]domain.User                       `json:"users"`type state struct {}	data state	path string	mu   sync.Mutextype Repository struct {)	"github.com/melion/fullstack-bible/backend/internal/domain"