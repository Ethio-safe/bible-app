package domain

import "time"

type User struct {
	ID           string    `json:"id"`
	Email        string    `json:"email"`
	DisplayName  string    `json:"displayName"`
	PasswordHash string    `json:"-"`
	CreatedAt    time.Time `json:"createdAt"`
	UpdatedAt    time.Time `json:"updatedAt"`
}

type Note struct {
	ID        string     `json:"id"`
	UserID    string     `json:"userId"`
	BookID    int        `json:"bookId"`
	Chapter   int        `json:"chapter"`
	Verse     int        `json:"verse"`
	Body      string     `json:"body"`
	DeviceID  string     `json:"deviceId,omitempty"`
	CreatedAt time.Time  `json:"createdAt"`
	UpdatedAt time.Time  `json:"updatedAt"`
	DeletedAt *time.Time `json:"deletedAt,omitempty"`
}

type Highlight struct {
	ID         string     `json:"id"`
	UserID     string     `json:"userId"`
	BookID     int        `json:"bookId"`
	Chapter    int        `json:"chapter"`
	VerseStart int        `json:"verseStart"`
	VerseEnd   int        `json:"verseEnd"`
	Color      int        `json:"color"`
	DeviceID   string     `json:"deviceId,omitempty"`
	CreatedAt  time.Time  `json:"createdAt"`
	UpdatedAt  time.Time  `json:"updatedAt"`
	DeletedAt  *time.Time `json:"deletedAt,omitempty"`
}

type Bookmark struct {
	ID        string     `json:"id"`
	UserID    string     `json:"userId"`
	BookID    int        `json:"bookId"`
	Chapter   int        `json:"chapter"`
	Verse     int        `json:"verse"`
	DeviceID  string     `json:"deviceId,omitempty"`
	CreatedAt time.Time  `json:"createdAt"`
	UpdatedAt time.Time  `json:"updatedAt"`
	DeletedAt *time.Time `json:"deletedAt,omitempty"`
}

type ReadingPosition struct {
	Translation  string     `json:"translation"`
	UserID       string     `json:"userId"`
	BookID       int        `json:"bookId"`
	Chapter      int        `json:"chapter"`
	ScrollOffset float64    `json:"scrollOffset"`
	DeviceID     string     `json:"deviceId,omitempty"`
	UpdatedAt    time.Time  `json:"updatedAt"`
	DeletedAt    *time.Time `json:"deletedAt,omitempty"`
}

type SyncSnapshot struct {
	User             User              `json:"user"`
	Notes            []Note            `json:"notes"`
	Highlights       []Highlight       `json:"highlights"`
	Bookmarks        []Bookmark        `json:"bookmarks"`
	ReadingPositions []ReadingPosition `json:"readingPositions"`
	ServerTime       time.Time         `json:"serverTime"`
}

type SyncPushRequest struct {
	Notes            []Note            `json:"notes"`
	Highlights       []Highlight       `json:"highlights"`
	Bookmarks        []Bookmark        `json:"bookmarks"`
	ReadingPositions []ReadingPosition `json:"readingPositions"`
}

type AuthTokens struct {
	AccessToken string    `json:"accessToken"`
	ExpiresAt   time.Time `json:"expiresAt"`
}