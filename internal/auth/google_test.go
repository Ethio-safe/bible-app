package auth

import (
	"context"
	"crypto/rand"
	"crypto/rsa"
	"encoding/base64"
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"google.golang.org/api/idtoken"
)

type roundTripperFunc func(*http.Request) (*http.Response, error)

func (f roundTripperFunc) RoundTrip(r *http.Request) (*http.Response, error) { return f(r) }

func TestGoogleVerifierChecksSignature(t *testing.T) {
	key, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatal(err)
	}
	otherKey, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatal(err)
	}
	n := base64.RawURLEncoding.EncodeToString(key.PublicKey.N.Bytes())
	keys := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Cache-Control", "public, max-age=60")
		fmt.Fprintf(w, `{"keys":[{"kid":"test-kid","kty":"RSA","alg":"RS256","use":"sig","n":%q,"e":"AQAB"}]}`, n)
	}))
	defer keys.Close()
	client := &http.Client{Transport: roundTripperFunc(func(req *http.Request) (*http.Response, error) {
		if req.URL.String() != "https://www.googleapis.com/oauth2/v3/certs" {
			return nil, fmt.Errorf("unexpected certificate URL: %s", req.URL)
		}
		copy := req.Clone(req.Context())
		copy.URL.Scheme = "http"
		copy.URL.Host = keys.Listener.Addr().String()
		return http.DefaultTransport.RoundTrip(copy)
	})}
	validator, err := idtoken.NewValidator(context.Background(), idtoken.WithHTTPClient(client))
	if err != nil {
		t.Fatal(err)
	}
	makeToken := func(signingKey *rsa.PrivateKey, claims jwt.MapClaims) string {
		t.Helper()
		signed := jwt.NewWithClaims(jwt.SigningMethodRS256, claims)
		signed.Header["kid"] = "test-kid"
		token, err := signed.SignedString(signingKey)
		if err != nil {
			t.Fatal(err)
		}
		return token
	}
	claims := jwt.MapClaims{
		"iss": "https://accounts.google.com", "aud": "web-client-id",
		"sub": "subject", "exp": time.Now().Add(time.Hour).Unix(),
		"email": "person@example.com", "email_verified": true,
	}
	verifier := GoogleTokenVerifier{
		ClientIDs: []string{"web-client-id"},
		validate:  validator.Validate,
	}
	if identity, err := verifier.Verify(context.Background(), makeToken(key, claims)); err != nil ||
		identity.Email != "person@example.com" {
		t.Fatalf("signed Google token rejected: %+v, %v", identity, err)
	}
	if _, err := verifier.Verify(context.Background(), makeToken(otherKey, claims)); !errors.Is(err, ErrInvalidGoogleToken) {
		t.Fatalf("wrong signature accepted: %v", err)
	}
}

func TestGoogleIdentityRequiresVerifiedClaims(t *testing.T) {
	base := idtoken.Payload{
		Issuer: "https://accounts.google.com", Audience: "client-id",
		Subject: "subject", Expires: time.Now().Add(time.Hour).Unix(),
		Claims: map[string]interface{}{
			"email": " Person@Example.com ", "email_verified": true,
			"name": "Person", "picture": "https://example.com/person.jpg",
		},
	}
	tests := []struct {
		name    string
		mutate  func(*idtoken.Payload)
		invalid bool
	}{
		{"verified", nil, false},
		{"untrusted issuer", func(p *idtoken.Payload) { p.Issuer = "https://attacker.example" }, true},
		{"expired", func(p *idtoken.Payload) { p.Expires = time.Now().Add(-time.Minute).Unix() }, true},
		{"wrong audience", func(p *idtoken.Payload) { p.Audience = "other" }, true},
		{"unverified email", func(p *idtoken.Payload) { p.Claims["email_verified"] = false }, true},
		{"missing email", func(p *idtoken.Payload) { delete(p.Claims, "email") }, true},
		{"missing subject", func(p *idtoken.Payload) { p.Subject = "" }, true},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			payload := base
			payload.Claims = make(map[string]interface{}, len(base.Claims))
			for key, value := range base.Claims {
				payload.Claims[key] = value
			}
			if tt.mutate != nil {
				tt.mutate(&payload)
			}
			v := GoogleTokenVerifier{
				ClientIDs: []string{"other", "client-id"},
				validate: func(_ context.Context, _, audience string) (*idtoken.Payload, error) {
					if audience != "client-id" {
						return nil, errors.New("wrong audience")
					}
					return &payload, nil
				},
			}
			identity, err := v.Verify(context.Background(), "signed-token")
			if tt.invalid {
				if !errors.Is(err, ErrInvalidGoogleToken) {
					t.Fatalf("expected invalid token, got %v", err)
				}
				return
			}
			if err != nil || identity.Email != "person@example.com" ||
				identity.DisplayName != "Person" || identity.PhotoURL != "https://example.com/person.jpg" {
				t.Fatalf("identity = %+v, err %v", identity, err)
			}
		})
	}
}

func TestGoogleVerifierRejectsInvalidToken(t *testing.T) {
	v := GoogleTokenVerifier{ClientIDs: []string{"client-id"}}
	for _, token := range []string{"", "not-a-jwt", string(make([]byte, 8193))} {
		if _, err := v.Verify(context.Background(), token); !errors.Is(err, ErrInvalidGoogleToken) {
			t.Fatalf("token accepted: %v", err)
		}
	}
}
