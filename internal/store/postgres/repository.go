package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/melion/fullstack-bible/backend/internal/domain"
	"github.com/melion/fullstack-bible/backend/internal/service"
)

const schema = `
CREATE TABLE IF NOT EXISTS users (
	id text PRIMARY KEY,
	email text NOT NULL UNIQUE,
	display_name text NOT NULL,
	photo_url text NOT NULL DEFAULT '',
	password_hash text NOT NULL,
	created_at timestamptz NOT NULL,
	updated_at timestamptz NOT NULL
);
ALTER TABLE users ADD COLUMN IF NOT EXISTS photo_url text NOT NULL DEFAULT '';
CREATE TABLE IF NOT EXISTS items (
	user_id text NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	kind text NOT NULL CHECK (kind IN ('note','highlight','bookmark','position')),
	id text NOT NULL,
	updated_at timestamptz NOT NULL,
	payload jsonb NOT NULL,
	PRIMARY KEY (user_id, kind, id)
);
CREATE INDEX IF NOT EXISTS items_user_kind_updated ON items (user_id, kind, updated_at DESC);
`

type Repository struct {
	pool *pgxpool.Pool
}

func Open(ctx context.Context, databaseURL string) (*Repository, error) {
	if strings.TrimSpace(databaseURL) == "" {
		return nil, errors.New("DATABASE_URL is required")
	}
	config, err := pgxpool.ParseConfig(databaseURL)
	if err != nil {
		return nil, fmt.Errorf("parse DATABASE_URL: %w", err)
	}
	config.MaxConns = 5
	pool, err := pgxpool.NewWithConfig(ctx, config)
	if err != nil {
		return nil, fmt.Errorf("open database: %w", err)
	}
	ctx, cancel := context.WithTimeout(ctx, 15*time.Second)
	defer cancel()
	if _, err := pool.Exec(ctx, schema); err != nil {
		pool.Close()
		return nil, fmt.Errorf("initialize database: %w", err)
	}
	return &Repository{pool: pool}, nil
}

func (r *Repository) Close() { r.pool.Close() }

func (r *Repository) Ping(ctx context.Context) error { return r.pool.Ping(ctx) }

func (r *Repository) CreateUser(user domain.User) (domain.User, error) {
	ctx, cancel := queryContext()
	defer cancel()
	_, err := r.pool.Exec(ctx, `INSERT INTO users (id,email,display_name,photo_url,password_hash,created_at,updated_at)
		VALUES ($1,$2,$3,$4,$5,$6,$7)`, user.ID, user.Email, user.DisplayName, user.PhotoURL, user.PasswordHash, user.CreatedAt, user.UpdatedAt)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) && pgErr.ConstraintName == "users_email_key" {
			return domain.User{}, service.ErrEmailTaken
		}
		return domain.User{}, err
	}
	return user, nil
}

func (r *Repository) UpsertGoogleUser(user domain.User) (domain.User, error) {
	ctx, cancel := queryContext()
	defer cancel()
	row := r.pool.QueryRow(ctx, `INSERT INTO users (id,email,display_name,photo_url,password_hash,created_at,updated_at)
		VALUES ($1,$2,$3,$4,$5,$6,$7)
		ON CONFLICT (email) DO UPDATE SET
			display_name=EXCLUDED.display_name,
			photo_url=EXCLUDED.photo_url,
			updated_at=EXCLUDED.updated_at
		RETURNING id,email,display_name,photo_url,password_hash,created_at,updated_at`,
		user.ID, user.Email, user.DisplayName, user.PhotoURL, user.PasswordHash, user.CreatedAt, user.UpdatedAt)
	saved, err := scanUser(row)
	if err != nil {
		return domain.User{}, err
	}
	return *saved, nil
}

func (r *Repository) FindUserByEmail(email string) (*domain.User, error) {
	ctx, cancel := queryContext()
	defer cancel()
	return scanUser(r.pool.QueryRow(ctx, `SELECT id,email,display_name,photo_url,password_hash,created_at,updated_at
		FROM users WHERE email=$1`, strings.ToLower(strings.TrimSpace(email))))
}

func (r *Repository) GetUserByID(id string) (*domain.User, error) {
	ctx, cancel := queryContext()
	defer cancel()
	return scanUser(r.pool.QueryRow(ctx, `SELECT id,email,display_name,photo_url,password_hash,created_at,updated_at
		FROM users WHERE id=$1`, id))
}

func scanUser(row pgx.Row) (*domain.User, error) {
	var user domain.User
	err := row.Scan(&user.ID, &user.Email, &user.DisplayName, &user.PhotoURL, &user.PasswordHash, &user.CreatedAt, &user.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, service.ErrNotFound
	}
	if err != nil {
		return nil, err
	}
	return &user, nil
}

type querier interface {
	Query(context.Context, string, ...any) (pgx.Rows, error)
	QueryRow(context.Context, string, ...any) pgx.Row
	Exec(context.Context, string, ...any) (pgconn.CommandTag, error)
}

func (r *Repository) Snapshot(userID string) (domain.SyncSnapshot, error) {
	ctx, cancel := queryContext()
	defer cancel()
	return snapshot(ctx, r.pool, userID)
}

func snapshot(ctx context.Context, db querier, userID string) (domain.SyncSnapshot, error) {
	user, err := scanUser(db.QueryRow(ctx, `SELECT id,email,display_name,photo_url,password_hash,created_at,updated_at
		FROM users WHERE id=$1`, userID))
	if err != nil {
		return domain.SyncSnapshot{}, err
	}
	out := domain.SyncSnapshot{
		User:  *user,
		Notes: []domain.Note{}, Highlights: []domain.Highlight{},
		Bookmarks: []domain.Bookmark{}, ReadingPositions: []domain.ReadingPosition{},
		ServerTime: time.Now().UTC(),
	}
	rows, err := db.Query(ctx, `SELECT kind,payload FROM items WHERE user_id=$1
		ORDER BY updated_at DESC, id`, userID)
	if err != nil {
		return domain.SyncSnapshot{}, err
	}
	defer rows.Close()
	for rows.Next() {
		var kind string
		var payload []byte
		if err := rows.Scan(&kind, &payload); err != nil {
			return domain.SyncSnapshot{}, err
		}
		switch kind {
		case "note":
			var v domain.Note
			err = json.Unmarshal(payload, &v)
			out.Notes = append(out.Notes, v)
		case "highlight":
			var v domain.Highlight
			err = json.Unmarshal(payload, &v)
			out.Highlights = append(out.Highlights, v)
		case "bookmark":
			var v domain.Bookmark
			err = json.Unmarshal(payload, &v)
			out.Bookmarks = append(out.Bookmarks, v)
		case "position":
			var v domain.ReadingPosition
			err = json.Unmarshal(payload, &v)
			out.ReadingPositions = append(out.ReadingPositions, v)
		default:
			return domain.SyncSnapshot{}, fmt.Errorf("unknown item kind %q", kind)
		}
		if err != nil {
			return domain.SyncSnapshot{}, fmt.Errorf("decode %s: %w", kind, err)
		}
	}
	if err := rows.Err(); err != nil {
		return domain.SyncSnapshot{}, err
	}
	return out, nil
}

func (r *Repository) ApplySync(userID string, push domain.SyncPushRequest) (domain.SyncSnapshot, error) {
	ctx, cancel := queryContext()
	defer cancel()
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return domain.SyncSnapshot{}, err
	}
	defer tx.Rollback(ctx)
	// Ensure a missing account (e.g. after an older ephemeral deployment) cannot
	// silently acknowledge a sync or cause orphaned items.
	var exists bool
	if err := tx.QueryRow(ctx, `SELECT EXISTS(SELECT 1 FROM users WHERE id=$1)`, userID).Scan(&exists); err != nil {
		return domain.SyncSnapshot{}, err
	}
	if !exists {
		return domain.SyncSnapshot{}, service.ErrNotFound
	}
	for _, v := range push.Notes {
		if err := upsert(ctx, tx, userID, "note", v.ID, v.UpdatedAt, v); err != nil {
			return domain.SyncSnapshot{}, err
		}
	}
	for _, v := range push.Highlights {
		if err := upsert(ctx, tx, userID, "highlight", v.ID, v.UpdatedAt, v); err != nil {
			return domain.SyncSnapshot{}, err
		}
	}
	for _, v := range push.Bookmarks {
		if err := upsert(ctx, tx, userID, "bookmark", v.ID, v.UpdatedAt, v); err != nil {
			return domain.SyncSnapshot{}, err
		}
	}
	for _, v := range push.ReadingPositions {
		if err := upsert(ctx, tx, userID, "position", v.Translation, v.UpdatedAt, v); err != nil {
			return domain.SyncSnapshot{}, err
		}
	}
	out, err := snapshot(ctx, tx, userID)
	if err != nil {
		return domain.SyncSnapshot{}, err
	}
	if err := tx.Commit(ctx); err != nil {
		return domain.SyncSnapshot{}, err
	}
	return out, nil
}

func upsert(ctx context.Context, db querier, userID, kind, id string, updatedAt time.Time, value any) error {
	if id == "" {
		return service.ErrInvalidSync
	}
	if updatedAt.IsZero() {
		return service.ErrInvalidSync
	}
	// Ignore a caller-supplied userId: row ownership and serialized ownership
	// must both derive from the authenticated user.
	switch v := value.(type) {
	case domain.Note:
		v.UserID = userID
		value = v
	case domain.Highlight:
		v.UserID = userID
		value = v
	case domain.Bookmark:
		v.UserID = userID
		value = v
	case domain.ReadingPosition:
		v.UserID = userID
		value = v
	}
	data, err := json.Marshal(value)
	if err != nil {
		return err
	}
	_, err = db.Exec(ctx, `INSERT INTO items (user_id,kind,id,updated_at,payload)
		VALUES ($1,$2,$3,$4,$5)
		ON CONFLICT (user_id,kind,id) DO UPDATE SET updated_at=EXCLUDED.updated_at,payload=EXCLUDED.payload
		WHERE items.updated_at <= EXCLUDED.updated_at`,
		userID, kind, id, updatedAt, data)
	return err
}

func queryContext() (context.Context, context.CancelFunc) {
	return context.WithTimeout(context.Background(), 10*time.Second)
}

func (r *Repository) UpsertNote(userID string, v domain.Note) (domain.Note, error) {
	ctx, cancel := queryContext()
	defer cancel()
	if err := upsert(ctx, r.pool, userID, "note", v.ID, v.UpdatedAt, v); err != nil {
		return domain.Note{}, err
	}
	return getItem[domain.Note](ctx, r.pool, userID, "note", v.ID)
}
func (r *Repository) UpsertHighlight(userID string, v domain.Highlight) (domain.Highlight, error) {
	ctx, cancel := queryContext()
	defer cancel()
	if err := upsert(ctx, r.pool, userID, "highlight", v.ID, v.UpdatedAt, v); err != nil {
		return domain.Highlight{}, err
	}
	return getItem[domain.Highlight](ctx, r.pool, userID, "highlight", v.ID)
}
func (r *Repository) UpsertBookmark(userID string, v domain.Bookmark) (domain.Bookmark, error) {
	ctx, cancel := queryContext()
	defer cancel()
	if err := upsert(ctx, r.pool, userID, "bookmark", v.ID, v.UpdatedAt, v); err != nil {
		return domain.Bookmark{}, err
	}
	return getItem[domain.Bookmark](ctx, r.pool, userID, "bookmark", v.ID)
}
func (r *Repository) UpsertReadingPosition(userID string, v domain.ReadingPosition) (domain.ReadingPosition, error) {
	ctx, cancel := queryContext()
	defer cancel()
	if err := upsert(ctx, r.pool, userID, "position", v.Translation, v.UpdatedAt, v); err != nil {
		return domain.ReadingPosition{}, err
	}
	return getItem[domain.ReadingPosition](ctx, r.pool, userID, "position", v.Translation)
}

func getItem[T any](ctx context.Context, db querier, userID, kind, id string) (T, error) {
	var value T
	var payload []byte
	err := db.QueryRow(ctx, `SELECT payload FROM items WHERE user_id=$1 AND kind=$2 AND id=$3`,
		userID, kind, id).Scan(&payload)
	if errors.Is(err, pgx.ErrNoRows) {
		return value, service.ErrNotFound
	}
	if err != nil {
		return value, err
	}
	err = json.Unmarshal(payload, &value)
	return value, err
}

func (r *Repository) DeleteNote(userID, id string) error {
	return r.deleteItem(userID, "note", id)
}
func (r *Repository) DeleteHighlight(userID, id string) error {
	return r.deleteItem(userID, "highlight", id)
}
func (r *Repository) DeleteBookmark(userID, id string) error {
	return r.deleteItem(userID, "bookmark", id)
}

func (r *Repository) deleteItem(userID, kind, id string) error {
	ctx, cancel := queryContext()
	defer cancel()
	now := time.Now().UTC()
	tag, err := r.pool.Exec(ctx, `UPDATE items
		SET updated_at=$4::timestamptz, payload=jsonb_set(jsonb_set(payload,'{updatedAt}',to_jsonb($4::timestamptz),true),'{deletedAt}',to_jsonb($4::timestamptz),true)
		WHERE user_id=$1 AND kind=$2 AND id=$3`,
		userID, kind, id, now)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return service.ErrNotFound
	}
	return nil
}

func (r *Repository) SearchNotes(userID, query string, limit int) ([]domain.Note, error) {
	ctx, cancel := queryContext()
	defer cancel()
	rows, err := r.pool.Query(ctx, `SELECT payload FROM items
		WHERE user_id=$1 AND kind='note' AND NOT (payload ? 'deletedAt')
		AND strpos(lower(payload->>'body'),lower($2)) > 0
		ORDER BY updated_at DESC LIMIT $3`, userID, strings.TrimSpace(query), limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	notes := []domain.Note{}
	for rows.Next() {
		var data []byte
		var note domain.Note
		if err := rows.Scan(&data); err != nil {
			return nil, err
		}
		if err := json.Unmarshal(data, &note); err != nil {
			return nil, err
		}
		notes = append(notes, note)
	}
	return notes, rows.Err()
}
