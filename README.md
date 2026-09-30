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
- `internal/store/postgres` – PostgreSQL persistence
- `internal/httpapi` – REST API and middleware

## What it supports now

- email/password registration
- email/password login
- verified Google ID-token login when `GOOGLE_CLIENT_IDS` is configured
- JWT bearer auth
- sync bootstrap endpoint
- bulk sync push endpoint
- CRUD-style endpoints for notes, highlights, bookmarks, and reading positions
- note search
- soft delete + last-write-wins conflict handling

## Persistence

PostgreSQL stores users and synced data durably. The server refuses to start without a
working `DATABASE_URL`; it never falls back to in-memory storage. The schema is created
on startup. Configure regular PostgreSQL backups; the server does not create backups
itself. Data previously held by the old in-memory deployment cannot be recovered after
its process has stopped. The Flutter client's local SQLite remains for offline reading.

## Configuration

| Variable | Required | Default | Notes |
| --- | --- | --- | --- |
| `JWT_SECRET` | **Yes** (in production) | `change-me-in-production` | Long random secret used to sign JWTs. The server refuses to start on Railway with the default value. |
| `CORS_ALLOWED_ORIGINS` | Yes for browser clients | `http://localhost:3000,http://localhost:8080` | Comma-separated list of allowed origins. |
| `PORT` | Set by platform | – | When set (and `HTTP_ADDR` is not), the server listens on `0.0.0.0:$PORT`. |
| `HTTP_ADDR` | No | `:8080` | Explicit listen address; overrides `PORT`. |
| `DATABASE_URL` | **Yes** | None | PostgreSQL connection URL. On Railway, use a Postgres service reference; never put credentials in source control. |
| `GOOGLE_CLIENT_IDS` | For Google sign-in | None | Comma-separated Google OAuth client IDs accepted as ID-token audiences. Use the Web client ID configured as Flutter's `serverClientId`. Without it, Google login returns 501. |

## Run

1. Create a PostgreSQL database, copy `.env.example` to `.env`, and set `DATABASE_URL`.
2. Set `JWT_SECRET`. Environment variables are not automatically loaded from `.env` by Go;
   export them in your shell (or use a local environment loader).
3. Start the server:

```sh
go run ./cmd/server
```

Server defaults to `:8080`.

## Deploy on Railway

The repository includes a `Dockerfile` (Go 1.24, static binary on distroless) and `railway.json`
(Dockerfile builder, health check on `/healthz`).

1. Add a **Postgres** service to the Railway project. Create the bible-app service from
   this repository (root directory `/`, branch `main`).
   Leave custom build/start commands empty so `railway.json` and the `Dockerfile` are used.
2. Open **Variables → Raw Editor** and paste (replace the secret with your own):

   ```env
   DATABASE_URL=${{Postgres.DATABASE_URL}}
   JWT_SECRET=<a newly generated private value>
   CORS_ALLOWED_ORIGINS=*
   GOOGLE_CLIENT_IDS=<your-web-client-id.apps.googleusercontent.com>
   ```

   - `JWT_SECRET` is required; the server exits on Railway if it is left at the default.
     Rotate any secret previously shared in chat; rotation signs out existing sessions.
   - Set `DATABASE_URL` with Railway's variable reference UI, selecting the Postgres
     service's `DATABASE_URL`. Check the actual service name if it is not `Postgres`.
     Do not paste or commit the database password. The service will not start until
     the reference resolves and Postgres is reachable.
   - Set `GOOGLE_CLIENT_IDS` to the Web OAuth client ID from Google Cloud Console that
     the Flutter app uses as `serverClientId`. This ID is not a client secret. The backend
     verifies Google's signature, token expiry, issuer, audience, and verified email.
     A verified Google email links to an existing email/password account with the same
     email and preserves its password; new Google-only accounts receive an unusable random
     password. A token never grants access when Google verification fails.
   - `CORS_ALLOWED_ORIGINS=*` allows any browser origin (safe here because auth uses bearer
     tokens, not cookies). Restrict it to your web domain(s) later, e.g. `https://app.example.com`.
     Native mobile clients are not affected by CORS.
   - Do not set `PORT` or `HTTP_ADDR`; Railway injects `PORT` and the server binds `0.0.0.0:$PORT`.
3. Deploy, then **Settings → Networking → Generate Domain**.
4. Verify: `curl https://<your-domain>/healthz` → `{"status":"ok"}`.
   The health check now verifies that PostgreSQL is reachable.

## API overview

### Public

- `GET /healthz`
- `POST /v1/auth/register`
- `POST /v1/auth/login`
- `POST /v1/auth/password-reset/request`
- `POST /v1/auth/google` with `{"idToken":"..."}` → same `{user,tokens}` shape as
  email login. Returns `401` for invalid tokens and `501` until `GOOGLE_CLIENT_IDS` is set.
  User responses include `photoUrl` (empty string if unknown). Existing users are
  migrated automatically on startup to include this field.

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
