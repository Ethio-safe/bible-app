package service

import (
	"strings"
	"time"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"

	"github.com/melion/fullstack-bible/backend/internal/auth"
	"github.com/melion/fullstack-bible/backend/internal/domain"
	"github.com/melion/fullstack-bible/backend/internal/store"
)

type Service struct {
	repo store.Repository
	jwt  *auth.Manager
}

func New(repo store.Repository, jwtManager *auth.Manager) *Service {
	return &Service{repo: repo, jwt: jwtManager}
}

func (s *Service) Register(email, password, displayName string) (domain.User, domain.AuthTokens, error) {
	email = normalizeEmail(email)
	if _, err := s.repo.FindUserByEmail(email); err == nil {
		return domain.User{}, domain.AuthTokens{}, ErrEmailTaken
	}
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return domain.User{}, domain.AuthTokens{}, err
	}
	now := time.Now().UTC()
	user := domain.User{
		ID:           uuid.NewString(),
		Email:        email,
		DisplayName:  strings.TrimSpace(displayName),
		PasswordHash: string(hash),
		CreatedAt:    now,
		UpdatedAt:    now,
	}
	if user.DisplayName == "" {
		user.DisplayName = email
	}
	user, err = s.repo.CreateUser(user)
	if err != nil {
		return domain.User{}, domain.AuthTokens{}, err
	}
	tokens, err := s.issueTokens(user)
	return user, tokens, err
}

func (s *Service) Login(email, password string) (domain.User, domain.AuthTokens, error) {
	user, err := s.repo.FindUserByEmail(normalizeEmail(email))
	if err != nil || user == nil {
		return domain.User{}, domain.AuthTokens{}, ErrInvalidCredentials
	}
	if bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password)) != nil {
		return domain.User{}, domain.AuthTokens{}, ErrInvalidCredentials
	}
	tokens, err := s.issueTokens(*user)
	return *user, tokens, err
}

func (s *Service) RequestPasswordReset(email string) error {
	_, _ = s.repo.FindUserByEmail(normalizeEmail(email))
	return nil
}

func (s *Service) GoogleLogin(_ string) (domain.User, domain.AuthTokens, error) {
	return domain.User{}, domain.AuthTokens{}, ErrGoogleNotReady
}

func (s *Service) Bootstrap(userID string) (domain.SyncSnapshot, error) {
	return s.repo.Snapshot(userID)
}

func (s *Service) Push(userID string, push domain.SyncPushRequest) (domain.SyncSnapshot, error) {
	return s.repo.ApplySync(userID, push)
}

func (s *Service) UpsertNote(userID string, note domain.Note) (domain.Note, error) {
	now := time.Now().UTC()
	if note.ID == "" {
		note.ID = uuid.NewString()
	}
	note.UserID = userID
	if note.CreatedAt.IsZero() {
		note.CreatedAt = now
	}
	if note.UpdatedAt.IsZero() {
		note.UpdatedAt = now
	}
	return s.repo.UpsertNote(userID, note)
}

func (s *Service) DeleteNote(userID, id string) error {
	return s.repo.DeleteNote(userID, id)
}

func (s *Service) UpsertHighlight(userID string, item domain.Highlight) (domain.Highlight, error) {
	now := time.Now().UTC()
	if item.ID == "" {
		item.ID = uuid.NewString()
	}
	item.UserID = userID
	if item.CreatedAt.IsZero() {
		item.CreatedAt = now
	}
	if item.UpdatedAt.IsZero() {
		item.UpdatedAt = now
	}
	return s.repo.UpsertHighlight(userID, item)
}

func (s *Service) DeleteHighlight(userID, id string) error {
	return s.repo.DeleteHighlight(userID, id)
}

func (s *Service) UpsertBookmark(userID string, item domain.Bookmark) (domain.Bookmark, error) {
	now := time.Now().UTC()
	if item.ID == "" {
		item.ID = uuid.NewString()
	}
	item.UserID = userID
	if item.CreatedAt.IsZero() {
		item.CreatedAt = now
	}
	if item.UpdatedAt.IsZero() {
		item.UpdatedAt = now
	}
	return s.repo.UpsertBookmark(userID, item)
}

func (s *Service) DeleteBookmark(userID, id string) error {
	return s.repo.DeleteBookmark(userID, id)
}

func (s *Service) UpsertReadingPosition(userID string, item domain.ReadingPosition) (domain.ReadingPosition, error) {
	item.UserID = userID
	if item.UpdatedAt.IsZero() {
		item.UpdatedAt = time.Now().UTC()
	}
	return s.repo.UpsertReadingPosition(userID, item)
}

func (s *Service) SearchNotes(userID, query string, limit int) ([]domain.Note, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	return s.repo.SearchNotes(userID, query, limit)
}

func (s *Service) issueTokens(user domain.User) (domain.AuthTokens, error) {
	token, expiresAt, err := s.jwt.Issue(user.ID, user.Email)
	if err != nil {
		return domain.AuthTokens{}, err
	}
	return domain.AuthTokens{AccessToken: token, ExpiresAt: expiresAt}, nil
}

func normalizeEmail(email string) string {
	return strings.ToLower(strings.TrimSpace(email))
}
