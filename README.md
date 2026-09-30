# Bible Go backend

Go HTTP API for the Bible app (the Flutter client lives in a separate repository). It is intended for:

- authentication
- cloud backup/sync for notes, highlights, bookmarks, and reading progress
- note search
- future multi-device support

## Folder layout

- `cmd/server` – app entrypoint
- `internal/config` – environment config
- `internal/auth` – JWT handling
- `internal/domain` – core models
- `internal/service` – business logic and sync rules
- `internal/store/memory` – in-memory persistence for a quick MVP
- `internal/httpapi` – REST API and middleware

## What it supports now

- email/password registration
- email/password login
- JWT bearer auth
- sync bootstrap endpoint
- bulk sync push endpoint
- CRUD-style endpoints for notes, highlights, bookmarks, and reading positions
- note search
- soft delete + last-write-wins conflict handling

## Production note

> **Warning: data is not persisted.** The server uses the in-memory store (`internal/store/memory`).
> All users, notes, highlights, bookmarks, and reading positions are lost whenever the process
> restarts or redeploys, and are not shared across multiple replicas. `DATA_FILE` is read by the
> config but currently unused (the file store in `internal/store/filestore` is excluded from the build).

For production, keep the HTTP/service layers and swap `memory` with PostgreSQL (planned; not implemented).

## Configuration

| Variable | Required | Default | Notes |
| --- | --- | --- | --- |
| `JWT_SECRET` | **Yes** (in production) | `change-me-in-production` | Long random secret used to sign JWTs. The server refuses to start on Railway with the default value. |
| `CORS_ALLOWED_ORIGINS` | Yes for browser clients | `http://localhost:3000,http://localhost:8080` | Comma-separated list of allowed origins. |
| `PORT` | Set by platform | – | When set (and `HTTP_ADDR` is not), the server listens on `0.0.0.0:$PORT`. |
| `HTTP_ADDR` | No | `:8080` | Explicit listen address; overrides `PORT`. |
| `DATA_FILE` | No | `./data/dev.json` | Currently unused. |

## Run

1. Copy `.env.example` to `.env`.
2. Set `JWT_SECRET`.
3. Start the server:

```sh
go run ./cmd/server
```

Server defaults to `:8080`.

## Deploy on Railway

The repository includes a `Dockerfile` (Go 1.24, static binary on distroless) and `railway.json`
(Dockerfile builder, health check on `/healthz`).

1. Create a Railway service from this repository (root directory `/`, branch `main`).
   Leave custom build/start commands empty so `railway.json` and the `Dockerfile` are used.
2. Open **Variables → Raw Editor** and paste (replace the secret with your own):

   ```env
   JWT_SECRET=<output of: openssl rand -hex 32>
   CORS_ALLOWED_ORIGINS=*
   ```

   - `JWT_SECRET` is required; the server exits on Railway if it is left at the default.
   - `CORS_ALLOWED_ORIGINS=*` allows any browser origin (safe here because auth uses bearer
     tokens, not cookies). Restrict it to your web domain(s) later, e.g. `https://app.example.com`.
     Native mobile clients are not affected by CORS.
   - Do not set `PORT` or `HTTP_ADDR`; Railway injects `PORT` and the server binds `0.0.0.0:$PORT`.
3. Deploy, then **Settings → Networking → Generate Domain**.
4. Verify: `curl https://<your-domain>/healthz` → `{"status":"ok"}`.

## API overview

### Public

- `GET /healthz`
- `POST /v1/auth/register`
- `POST /v1/auth/login`
- `POST /v1/auth/password-reset/request`
- `POST /v1/auth/google` → currently returns `501` placeholder

### Authenticated

Use `Authorization: Bearer <token>`.

- `GET /v1/sync/bootstrap`
- `POST /v1/sync/push`
- `POST /v1/notes`
- `PUT /v1/notes/{id}`
- `DELETE /v1/notes/{id}`
- `POST /v1/highlights`
- `PUT /v1/highlights/{id}`
- `DELETE /v1/highlights/{id}`
- `POST /v1/bookmarks`
- `PUT /v1/bookmarks/{id}`
- `DELETE /v1/bookmarks/{id}`
- `PUT /v1/reading-positions/{translation}`
- `GET /v1/search?q=grace&limit=20`

## Flutter mapping

The backend mirrors the Flutter app's local data concepts (in the separate app repository):

- `lib/features/annotations/domain/entities/annotations.dart`
- `lib/features/auth/presentation/providers/auth_provider.dart`
- `lib/core/backup/backup_service.dart`

## Suggested next step in Flutter

Add a sync repository that:

- keeps local Drift as source of truth for offline mode
- queues local writes
- sends batched changes to `POST /v1/sync/push`
- refreshes from `GET /v1/sync/bootstrap` on login/app resume
