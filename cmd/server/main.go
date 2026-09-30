package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/melion/fullstack-bible/backend/internal/auth"
	"github.com/melion/fullstack-bible/backend/internal/config"
	"github.com/melion/fullstack-bible/backend/internal/httpapi"
	"github.com/melion/fullstack-bible/backend/internal/service"
	"github.com/melion/fullstack-bible/backend/internal/store/memory"
)

func main() {
	cfg := config.Load()
	if cfg.JWTSecret == "change-me-in-production" {
		if os.Getenv("RAILWAY_ENVIRONMENT") != "" || os.Getenv("RAILWAY_ENVIRONMENT_NAME") != "" {
			log.Fatal("JWT_SECRET must be set to a strong secret in deployed environments")
		}
		log.Print("warning: using default JWT_SECRET; set JWT_SECRET before deploying")
	}

	repo := memory.New()
	jwtManager := auth.NewManager(cfg.JWTSecret, 24*time.Hour)
	svc := service.New(repo, jwtManager)
	handler := httpapi.NewRouter(cfg, svc, jwtManager)

	server := &http.Server{
		Addr:              cfg.HTTPAddr,
		Handler:           handler,
		ReadHeaderTimeout: 5 * time.Second,
	}

	go func() {
		log.Printf("backend listening on %s", cfg.HTTPAddr)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("server error: %v", err)
		}
	}()

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	<-ctx.Done()

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := server.Shutdown(shutdownCtx); err != nil {
		log.Printf("shutdown error: %v", err)
	}
}
