package store

import "github.com/melion/fullstack-bible/backend/internal/domain"

type Repository interface {
	CreateUser(user domain.User) (domain.User, error)
	FindUserByEmail(email string) (*domain.User, error)
	GetUserByID(id string) (*domain.User, error)
	Snapshot(userID string) (domain.SyncSnapshot, error)
	ApplySync(userID string, push domain.SyncPushRequest) (domain.SyncSnapshot, error)
	UpsertNote(userID string, note domain.Note) (domain.Note, error)
	DeleteNote(userID, id string) error
	UpsertHighlight(userID string, highlight domain.Highlight) (domain.Highlight, error)
	DeleteHighlight(userID, id string) error
	UpsertBookmark(userID string, bookmark domain.Bookmark) (domain.Bookmark, error)
	DeleteBookmark(userID, id string) error
	UpsertReadingPosition(userID string, position domain.ReadingPosition) (domain.ReadingPosition, error)
	SearchNotes(userID, query string, limit int) ([]domain.Note, error)

}