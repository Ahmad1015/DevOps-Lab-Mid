# DevOps-Lab-Mid

Full-stack FARM starter (FastAPI + React + MongoDB + Docker) that ships with password and Google SSO authentication, a Material UI front-end, and a Mongo-backed user management API. This README explains how the pieces fit together and how to run, test, and extend the project.

## Overview
- **Backend**: FastAPI service (`backend/app`) with Beanie ODM on MongoDB, JWT auth, Google OAuth2 SSO, and CRUD for user profiles.
- **Frontend**: React 19 + Vite app (`frontend/src`) styled with Material UI, featuring login/register flows, profile management, and an admin-only user directory.
- **Infrastructure**: Docker Compose orchestrates the web app, API, and MongoDB with hot-reload volumes for local development.

```
[ React (Vite) ]  ⇄  [ FastAPI + Beanie ]  ⇄  [ MongoDB ]
```

## Features
- Email/password login with JWTs stored in `localStorage` and refresh via HttpOnly cookie after Google SSO.
- Google OAuth2 login support with automatic user provisioning and optional Traditional signup toggle.
- User self-service: profile editing, password change, account deletion.
- Superuser console: list users, update flags, delete accounts.
- Comprehensive tests: `pytest` API suite with async fixtures, Vitest UI tests with Testing Library.

## Project Layout
- `backend/app/` – FastAPI application, routers, auth helpers, Beanie models, settings.
- `backend/tests/` – Async `pytest` suite covering login and user flows (uses temporary Mongo database).
- `frontend/src/` – React app with routes, contexts, Material UI components, and Vitest specs.
- `docker-compose.yml` – Dev stack: MongoDB, backend (uv + FastAPI reload), frontend (Vite dev server).

## Prerequisites
- Docker & Docker Compose (for the quickest start).
- Node.js 22 LTS (if running the frontend outside Docker).
- Python 3.12 with [uv](https://docs.astral.sh/uv/) (for backend development without Docker).

## Configuration
Create a root-level `.env` file (the backend reads `../.env` relative to `backend/`). Adjust values to your environment:

```
# ---------- Shared ----------
PROJECT_NAME=FARMD
MONGO_HOST=db
MONGO_PORT=27017
MONGO_USER=farmd
MONGO_PASSWORD=change-me
MONGO_DB=farmd

# ---------- Initial Superuser (seeded on first start) ----------
FIRST_SUPERUSER=admin@example.com
FIRST_SUPERUSER_PASSWORD=ChangeMe123!

# JSON array of allowed origins (must match Vite dev URL when running locally)
BACKEND_CORS_ORIGINS=["http://localhost:5173"]

# ---------- Optional Google SSO ----------
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
SSO_CALLBACK_HOSTNAME=http://localhost:8000
SSO_LOGIN_CALLBACK_URL=http://localhost:5173/sso-login-callback

# ---------- Frontend (Vite) ----------
VITE_BACKEND_API_URL=http://localhost:8000/api/v1/
VITE_PWD_SIGNUP_ENABLED=true
VITE_GA_TRACKING_ID=
VITE_BASE_PATH=/
```

> ℹ️ `BACKEND_CORS_ORIGINS` must be valid JSON. The backend generates its own `SECRET_KEY` at runtime unless you override it via the environment.

## Run with Docker Compose
1. `docker compose up --build`
2. Visit the app at `http://localhost:5173`
3. Explore the API docs at `http://localhost:8000/docs`

MongoDB data persists in the `mongodb-data` Docker volume. The backend seeds the `FIRST_SUPERUSER` credentials if the email is not found.

## Local Development (Without Docker)

### Backend
1. `cd backend`
2. `uv sync` (installs dependencies into `.venv`)
3. `uv run fastapi dev app/main.py` (reload server on `http://localhost:8000`)

**Tests & tooling**
- `uv run pytest` – Run backend tests (uses ephemeral `farmdtest` DB).
- `uv run ruff check app tests` – Lint.
- `uv run mypy` – Type-check.

Ensure MongoDB is reachable at the host/port specified in `.env` when running outside Docker.

### Frontend
1. `cd frontend`
2. `npm ci`
3. `npm run dev` (Vite dev server on `http://localhost:5173`)

**Quality checks**
- `npm run test` – Vitest UI suite.
- `npm run coverage` – Coverage report.
- `npm run lint` / `npm run format` – ESLint & Prettier.

## API Highlights (`/api/v1`)
- `POST /login/access-token` – OAuth2 password flow, returns JWT.
- `GET /login/refresh-token` – Issue a new token for the cookie-authenticated user (used by SSO callback).
- `GET /users/me` – Authenticated user profile.
- `PATCH /users/me` – Update own profile/password (email uniqueness enforced).
- `POST /users` – Register new account (public).
- `GET /users` – List users (superuser only, supports limit/offset).
- `PATCH /users/{uuid}` / `DELETE /users/{uuid}` – Superuser management endpoints.

All responses use Pydantic schemas; authentication relies on Bearer tokens set by the frontend `AuthProvider` context.

## Frontend Routes
- `/` – Landing page describing the stack with live GitHub star counts cached in `localStorage`.
- `/login` – Password login with optional Google SSO redirect (`/api/v1/login/google`).
- `/register` – Google-onboarding first; email/password form toggled by `VITE_PWD_SIGNUP_ENABLED`.
- `/profile` – Self-service profile editor with password reset and self-delete.
- `/users` – Superuser-only directory with inline edit/delete using `UserProfile`.
- `/sso-login-callback` – Consumes Google SSO cookie, refreshes JWT, then redirects to home.

## Testing Notes
- Backend fixtures patch the DB name to `farmdtest` and clear collections after each test, preventing data leakage.
- Frontend tests (Vitest + Testing Library + MSW) cover key components such as forms, menus, and auth context interactions.

## Next Steps
- Configure Google OAuth credentials in `.env`, then the login button at `/login` will redirect to Google's consent screen.
- Extend the API by adding additional routers under `backend/app/routers` and update `api_router.include_router`.
- Update the Material UI theme in `frontend/src/theme.tsx` to match your branding.