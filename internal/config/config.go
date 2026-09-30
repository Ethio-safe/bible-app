package config

import (
	"os"
	"strings"
)

type Config struct {
	HTTPAddr           string
	JWTSecret          string
	DatabaseURL        string
	GoogleClientIDs    []string
	CORSAllowedOrigins []string
}

func Load() Config {
	return Config{
		HTTPAddr:           httpAddr(),
		JWTSecret:          getenv("JWT_SECRET", "change-me-in-production"),
		DatabaseURL:        strings.TrimSpace(os.Getenv("DATABASE_URL")),
		GoogleClientIDs:    splitCSV(os.Getenv("GOOGLE_CLIENT_IDS")),
		CORSAllowedOrigins: splitCSV(getenv("CORS_ALLOWED_ORIGINS", "http://localhost:3000,http://localhost:8080")),
	}
}

// httpAddr prefers an explicit HTTP_ADDR, then the platform-provided PORT
// (e.g. Railway), bound on all interfaces, and finally falls back to :8080.
func httpAddr() string {
	if addr := strings.TrimSpace(os.Getenv("HTTP_ADDR")); addr != "" {
		return addr
	}
	if port := strings.TrimSpace(os.Getenv("PORT")); port != "" {
		return "0.0.0.0:" + port
	}
	return ":8080"
}

func getenv(key, fallback string) string {
	if value := strings.TrimSpace(os.Getenv(key)); value != "" {
		return value
	}
	return fallback
}

func splitCSV(value string) []string {
	parts := strings.Split(value, ",")
	out := make([]string, 0, len(parts))
	for _, part := range parts {
		part = strings.TrimSpace(part)
		if part != "" {
			out = append(out, part)
		}
	}
	return out
}
