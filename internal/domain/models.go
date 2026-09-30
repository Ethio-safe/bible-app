//go:build ignore
// +build ignore

package domain
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



































































}	ExpiresAt   time.Time `json:"expiresAt"`	AccessToken string    `json:"accessToken"`type AuthTokens struct {}	ReadingPositions []ReadingPosition `json:"readingPositions"`	Bookmarks        []Bookmark        `json:"bookmarks"`	Highlights       []Highlight       `json:"highlights"`	Notes            []Note            `json:"notes"`type SyncPushRequest struct {}	ServerTime       time.Time         `json:"serverTime"`	ReadingPositions []ReadingPosition `json:"readingPositions"`	Bookmarks        []Bookmark        `json:"bookmarks"`	Highlights       []Highlight       `json:"highlights"`	Notes            []Note            `json:"notes"`	User             User              `json:"user"`type SyncSnapshot struct {}	DeletedAt   *time.Time `json:"deletedAt,omitempty"`	UpdatedAt   time.Time  `json:"updatedAt"`	DeviceID    string     `json:"deviceId,omitempty"`	ScrollOffset float64   `json:"scrollOffset"`	Chapter     int        `json:"chapter"`	BookID      int        `json:"bookId"`	UserID      string     `json:"userId"`	Translation string     `json:"translation"`type ReadingPosition struct {}	DeletedAt *time.Time `json:"deletedAt,omitempty"`	UpdatedAt time.Time  `json:"updatedAt"`	CreatedAt time.Time  `json:"createdAt"`	DeviceID  string     `json:"deviceId,omitempty"`	Verse     int        `json:"verse"`	Chapter   int        `json:"chapter"`	BookID    int        `json:"bookId"`	UserID    string     `json:"userId"`	ID        string     `json:"id"`type Bookmark struct {}	DeletedAt  *time.Time `json:"deletedAt,omitempty"`	UpdatedAt  time.Time  `json:"updatedAt"`	CreatedAt  time.Time  `json:"createdAt"`	DeviceID   string     `json:"deviceId,omitempty"`	Color      int        `json:"color"`	VerseEnd   int        `json:"verseEnd"`	VerseStart int        `json:"verseStart"`	Chapter    int        `json:"chapter"`	BookID     int        `json:"bookId"`	UserID     string     `json:"userId"`	ID         string     `json:"id"`type Highlight struct {}	DeletedAt *time.Time `json:"deletedAt,omitempty"`	UpdatedAt time.Time  `json:"updatedAt"`	CreatedAt time.Time  `json:"createdAt"`	DeviceID  string     `json:"deviceId,omitempty"`	Body      string     `json:"body"`	Verse     int        `json:"verse"`	Chapter   int        `json:"chapter"`	BookID    int        `json:"bookId"`