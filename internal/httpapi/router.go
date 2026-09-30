package httpapi

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"strconv"
	"strings"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/cors"

	"github.com/melion/fullstack-bible/backend/internal/auth"
	"github.com/melion/fullstack-bible/backend/internal/config"
	"github.com/melion/fullstack-bible/backend/internal/domain"
	"github.com/melion/fullstack-bible/backend/internal/service"
)

type contextKey string

const userIDKey contextKey = "userID"

type Router struct {
	service *service.Service
	jwt     *auth.Manager
}

func NewRouter(cfg config.Config, svc *service.Service, jwtManager *auth.Manager) http.Handler {
	r := chi.NewRouter()
	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   cfg.CORSAllowedOrigins,
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type"},
		AllowCredentials: false,
		MaxAge:           300,
	}))

	api := &Router{service: svc, jwt: jwtManager}

	r.Get("/healthz", api.healthz)
	r.Route("/v1", func(r chi.Router) {
		r.Route("/auth", func(r chi.Router) {
			r.Post("/register", api.register)
			r.Post("/login", api.login)
			r.Post("/password-reset/request", api.passwordReset)
			r.Post("/google", api.googleLogin)
		})

		r.Group(func(r chi.Router) {
			r.Use(api.requireAuth)
			r.Get("/sync/bootstrap", api.bootstrap)
			r.Post("/sync/push", api.push)
			r.Post("/notes", api.createNote)
			r.Put("/notes/{id}", api.updateNote)
			r.Delete("/notes/{id}", api.deleteNote)
			r.Post("/highlights", api.createHighlight)
			r.Put("/highlights/{id}", api.updateHighlight)
			r.Delete("/highlights/{id}", api.deleteHighlight)
			r.Post("/bookmarks", api.createBookmark)
			r.Put("/bookmarks/{id}", api.updateBookmark)
			r.Delete("/bookmarks/{id}", api.deleteBookmark)
			r.Put("/reading-positions/{translation}", api.upsertReadingPosition)
			r.Get("/search", api.search)
		})
	})

	return r
}

type authRequest struct {
	Email       string `json:"email"`
	Password    string `json:"password"`
	DisplayName string `json:"displayName"`
}

type googleAuthRequest struct {
	IDToken string `json:"idToken"`
}

type authResponse struct {
	User   domain.User       `json:"user"`
	Tokens domain.AuthTokens `json:"tokens"`
}

func (rt *Router) healthz(w http.ResponseWriter, r *http.Request) {
	if err := rt.service.Ping(r.Context()); err != nil {
		respondError(w, http.StatusServiceUnavailable, errors.New("database unavailable"))
		return
	}
	respondJSON(w, http.StatusOK, map[string]string{"status": "ok"})
}

func (rt *Router) register(w http.ResponseWriter, r *http.Request) {
	var req authRequest
	if err := decodeJSON(r, &req); err != nil {
		respondError(w, http.StatusBadRequest, err)
		return
	}
	user, tokens, err := rt.service.Register(req.Email, req.Password, req.DisplayName)
	if err != nil {
		status := http.StatusInternalServerError
		if errors.Is(err, service.ErrEmailTaken) {
			status = http.StatusConflict
		} else if errors.Is(err, service.ErrInvalidRegistration) {
			status = http.StatusBadRequest
		}
		respondError(w, status, err)
		return
	}
	respondJSON(w, http.StatusCreated, authResponse{User: user, Tokens: tokens})
}

func (rt *Router) login(w http.ResponseWriter, r *http.Request) {
	var req authRequest
	if err := decodeJSON(r, &req); err != nil {
		respondError(w, http.StatusBadRequest, err)
		return
	}
	user, tokens, err := rt.service.Login(req.Email, req.Password)
	if err != nil {
		status := http.StatusInternalServerError
		if errors.Is(err, service.ErrInvalidCredentials) {
			status = http.StatusUnauthorized
		}
		respondError(w, status, err)
		return
	}
	respondJSON(w, http.StatusOK, authResponse{User: user, Tokens: tokens})
}

func (rt *Router) passwordReset(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Email string `json:"email"`
	}
	if err := decodeJSON(r, &req); err != nil {
		respondError(w, http.StatusBadRequest, err)
		return
	}
	if err := rt.service.RequestPasswordReset(req.Email); err != nil {
		respondError(w, http.StatusInternalServerError, err)
		return
	}
	respondJSON(w, http.StatusAccepted, map[string]string{"status": "queued"})
}

func (rt *Router) googleLogin(w http.ResponseWriter, r *http.Request) {
	var req googleAuthRequest
	if err := decodeJSON(r, &req); err != nil {
		respondError(w, http.StatusBadRequest, err)
		return
	}
	_, _, err := rt.service.GoogleLogin(req.IDToken)
	respondError(w, http.StatusNotImplemented, err)
}

func (rt *Router) bootstrap(w http.ResponseWriter, r *http.Request) {
	snapshot, err := rt.service.Bootstrap(userIDFromContext(r.Context()))
	if err != nil {
		status := http.StatusInternalServerError
		if errors.Is(err, service.ErrNotFound) {
			status = http.StatusUnauthorized
		}
		respondError(w, status, err)
		return
	}
	respondJSON(w, http.StatusOK, snapshot)
}

func (rt *Router) push(w http.ResponseWriter, r *http.Request) {
	var req domain.SyncPushRequest
	if err := decodeJSON(r, &req); err != nil {
		respondError(w, http.StatusBadRequest, err)
		return
	}
	snapshot, err := rt.service.Push(userIDFromContext(r.Context()), req)
	if err != nil {
		status := http.StatusInternalServerError
		if errors.Is(err, service.ErrNotFound) {
			status = http.StatusUnauthorized
		} else if errors.Is(err, service.ErrInvalidSync) {
			status = http.StatusBadRequest
		}
		respondError(w, status, err)
		return
	}
	respondJSON(w, http.StatusOK, snapshot)
}

func (rt *Router) createNote(w http.ResponseWriter, r *http.Request) {
	var item domain.Note
	if err := decodeJSON(r, &item); err != nil {
		respondError(w, http.StatusBadRequest, err)
		return
	}
	item, err := rt.service.UpsertNote(userIDFromContext(r.Context()), item)
	if err != nil {
		respondError(w, http.StatusInternalServerError, err)
		return
	}
	respondJSON(w, http.StatusCreated, item)
}

func (rt *Router) updateNote(w http.ResponseWriter, r *http.Request) {
	var item domain.Note
	if err := decodeJSON(r, &item); err != nil {
		respondError(w, http.StatusBadRequest, err)
		return
	}
	item.ID = chi.URLParam(r, "id")
	item, err := rt.service.UpsertNote(userIDFromContext(r.Context()), item)
	if err != nil {
		respondError(w, http.StatusInternalServerError, err)
		return
	}
	respondJSON(w, http.StatusOK, item)
}

func (rt *Router) deleteNote(w http.ResponseWriter, r *http.Request) {
	if err := rt.service.DeleteNote(userIDFromContext(r.Context()), chi.URLParam(r, "id")); err != nil {
		status := http.StatusInternalServerError
		if errors.Is(err, service.ErrNotFound) {
			status = http.StatusNotFound
		}
		respondError(w, status, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (rt *Router) createHighlight(w http.ResponseWriter, r *http.Request) {
	var item domain.Highlight
	if err := decodeJSON(r, &item); err != nil {
		respondError(w, http.StatusBadRequest, err)
		return
	}
	item, err := rt.service.UpsertHighlight(userIDFromContext(r.Context()), item)
	if err != nil {
		respondError(w, http.StatusInternalServerError, err)
		return
	}
	respondJSON(w, http.StatusCreated, item)
}

func (rt *Router) updateHighlight(w http.ResponseWriter, r *http.Request) {
	var item domain.Highlight
	if err := decodeJSON(r, &item); err != nil {
		respondError(w, http.StatusBadRequest, err)
		return
	}
	item.ID = chi.URLParam(r, "id")
	item, err := rt.service.UpsertHighlight(userIDFromContext(r.Context()), item)
	if err != nil {
		respondError(w, http.StatusInternalServerError, err)
		return
	}
	respondJSON(w, http.StatusOK, item)
}

func (rt *Router) deleteHighlight(w http.ResponseWriter, r *http.Request) {
	if err := rt.service.DeleteHighlight(userIDFromContext(r.Context()), chi.URLParam(r, "id")); err != nil {
		status := http.StatusInternalServerError
		if errors.Is(err, service.ErrNotFound) {
			status = http.StatusNotFound
		}
		respondError(w, status, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (rt *Router) createBookmark(w http.ResponseWriter, r *http.Request) {
	var item domain.Bookmark
	if err := decodeJSON(r, &item); err != nil {
		respondError(w, http.StatusBadRequest, err)
		return
	}
	item, err := rt.service.UpsertBookmark(userIDFromContext(r.Context()), item)
	if err != nil {
		respondError(w, http.StatusInternalServerError, err)
		return
	}
	respondJSON(w, http.StatusCreated, item)
}

func (rt *Router) updateBookmark(w http.ResponseWriter, r *http.Request) {
	var item domain.Bookmark
	if err := decodeJSON(r, &item); err != nil {
		respondError(w, http.StatusBadRequest, err)
		return
	}
	item.ID = chi.URLParam(r, "id")
	item, err := rt.service.UpsertBookmark(userIDFromContext(r.Context()), item)
	if err != nil {
		respondError(w, http.StatusInternalServerError, err)
		return
	}
	respondJSON(w, http.StatusOK, item)
}

func (rt *Router) deleteBookmark(w http.ResponseWriter, r *http.Request) {
	if err := rt.service.DeleteBookmark(userIDFromContext(r.Context()), chi.URLParam(r, "id")); err != nil {
		status := http.StatusInternalServerError
		if errors.Is(err, service.ErrNotFound) {
			status = http.StatusNotFound
		}
		respondError(w, status, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (rt *Router) upsertReadingPosition(w http.ResponseWriter, r *http.Request) {
	var item domain.ReadingPosition
	if err := decodeJSON(r, &item); err != nil {
		respondError(w, http.StatusBadRequest, err)
		return
	}
	item.Translation = chi.URLParam(r, "translation")
	item, err := rt.service.UpsertReadingPosition(userIDFromContext(r.Context()), item)
	if err != nil {
		respondError(w, http.StatusInternalServerError, err)
		return
	}
	respondJSON(w, http.StatusOK, item)
}

func (rt *Router) search(w http.ResponseWriter, r *http.Request) {
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	items, err := rt.service.SearchNotes(userIDFromContext(r.Context()), r.URL.Query().Get("q"), limit)
	if err != nil {
		respondError(w, http.StatusInternalServerError, err)
		return
	}
	respondJSON(w, http.StatusOK, map[string]any{"notes": items})
}

func (rt *Router) requireAuth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		header := strings.TrimSpace(r.Header.Get("Authorization"))
		if !strings.HasPrefix(strings.ToLower(header), "bearer ") {
			respondError(w, http.StatusUnauthorized, errors.New("missing bearer token"))
			return
		}
		claims, err := rt.jwt.Parse(strings.TrimSpace(header[7:]))
		if err != nil {
			respondError(w, http.StatusUnauthorized, err)
			return
		}
		ctx := context.WithValue(r.Context(), userIDKey, claims.UserID)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

func userIDFromContext(ctx context.Context) string {
	value, _ := ctx.Value(userIDKey).(string)
	return value
}

func decodeJSON(r *http.Request, dst any) error {
	defer r.Body.Close()
	r.Body = http.MaxBytesReader(nil, r.Body, 8<<20)
	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(dst); err != nil {
		return err
	}
	if decoder.Decode(new(any)) != io.EOF {
		return errors.New("expected a single JSON object")
	}
	return nil
}

func respondJSON(w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(payload)
}

func respondError(w http.ResponseWriter, status int, err error) {
	if err == nil {
		err = errors.New(http.StatusText(status))
	}
	respondJSON(w, status, map[string]string{"error": err.Error()})
}
