package auth

import (
	"context"
	"errors"
	"strings"
	"time"

	"google.golang.org/api/idtoken"
)

var ErrInvalidGoogleToken = errors.New("invalid Google ID token")

type GoogleIdentity struct {
	Email       string
	DisplayName string
	PhotoURL    string
}

type GoogleVerifier interface {
	Verify(ctx context.Context, token string) (GoogleIdentity, error)
}

type GoogleTokenVerifier struct {
	ClientIDs []string
	validate  func(context.Context, string, string) (*idtoken.Payload, error)
}

func (v GoogleTokenVerifier) Verify(ctx context.Context, token string) (GoogleIdentity, error) {
	if token == "" || len(token) > 8192 {
		return GoogleIdentity{}, ErrInvalidGoogleToken
	}
	validate := v.validate
	if validate == nil {
		validate = idtoken.Validate
	}
	ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()
	for _, clientID := range v.ClientIDs {
		payload, err := validate(ctx, token, clientID)
		if err != nil {
			continue
		}
		if payload == nil || payload.Audience != clientID || payload.Expires <= time.Now().Unix() ||
			(payload.Issuer != "accounts.google.com" && payload.Issuer != "https://accounts.google.com") {
			return GoogleIdentity{}, ErrInvalidGoogleToken
		}
		verified, ok := payload.Claims["email_verified"].(bool)
		email, emailOK := payload.Claims["email"].(string)
		email = strings.ToLower(strings.TrimSpace(email))
		if !ok || !verified || !emailOK || email == "" || !strings.Contains(email, "@") || payload.Subject == "" {
			return GoogleIdentity{}, ErrInvalidGoogleToken
		}
		name, _ := payload.Claims["name"].(string)
		picture, _ := payload.Claims["picture"].(string)
		return GoogleIdentity{
			Email:       email,
			DisplayName: strings.TrimSpace(name),
			PhotoURL:    strings.TrimSpace(picture),
		}, nil
	}
	return GoogleIdentity{}, ErrInvalidGoogleToken
}
