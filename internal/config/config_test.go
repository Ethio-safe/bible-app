package config

import "testing"

func TestHTTPAddr(t *testing.T) {
	tests := []struct {
		name, httpAddr, port, want string
	}{
		{"default", "", "", ":8080"},
		{"platform port", "", "4321", "0.0.0.0:4321"},
		{"explicit addr wins", "127.0.0.1:9000", "4321", "127.0.0.1:9000"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Setenv("HTTP_ADDR", tt.httpAddr)
			t.Setenv("PORT", tt.port)
			if got := Load().HTTPAddr; got != tt.want {
				t.Fatalf("HTTPAddr = %q, want %q", got, tt.want)
			}
		})
	}
}

func TestCORSWildcard(t *testing.T) {
	t.Setenv("CORS_ALLOWED_ORIGINS", "*")
	got := Load().CORSAllowedOrigins
	if len(got) != 1 || got[0] != "*" {
		t.Fatalf("CORSAllowedOrigins = %v, want [*]", got)
	}
}

func TestGoogleClientIDs(t *testing.T) {
	t.Setenv("GOOGLE_CLIENT_IDS", " first.apps.googleusercontent.com , second.apps.googleusercontent.com ")
	got := Load().GoogleClientIDs
	if len(got) != 2 || got[0] != "first.apps.googleusercontent.com" || got[1] != "second.apps.googleusercontent.com" {
		t.Fatalf("GoogleClientIDs = %v", got)
	}
}
