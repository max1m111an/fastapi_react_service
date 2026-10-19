# fastapi_react_service

Template repository for a full-stack service: **FastAPI + React + MariaDB + Nginx**, fully wired for Docker Compose.

- **Backend** — FastAPI (async SQLAlchemy + aiomysql) served by Uvicorn.
- **Frontend** — React (built with Vite) served as static files by Nginx.
- **Database** — MariaDB with automatic schema creation on startup.
- **Nginx** — single entry point: proxies `/api`, `/docs`, `/openapi.json` to the backend and `/` to the frontend.
- **Adminer** — lightweight DB web UI.

---

## Table of contents

- [Quick start](#quick-start)
- [Services and ports](#services-and-ports)
- [API](#api)
- [Environment variables](#environment-variables)
- [Development](#development)
- [Make targets](#make-targets)
- [Project structure](#project-structure)

---

## Quick start

```bash
# start the whole stack (build + run in background)
docker compose up --build -d

# follow logs
docker compose logs -f

# stop and remove containers (drops DB volume!)
docker compose down -v
```

Open <http://localhost> — the React app is served through Nginx and talks to the API at `/api`.

---

## Services and ports

| Service    | Container  | Image / build stage    | Host port             | Description                                  |
| ---------- | ---------- | ---------------------- | --------------------- | -------------------------------------------- |
| `nginx`    | `nginx`    | `Dockerfile` → `nginx` | `80`                  | Entry point: static frontend + API reverse proxy |
| `frontend` | `frontend` | `Dockerfile` → `frontend` | `${FRONTEND_PORT:-3000}` → 80 | React build served by Nginx          |
| `fastapi`  | `fastapi`  | `Dockerfile` → `fastapi`  | `${APP_PORT:-8080}`   | Uvicorn running `apps/backend/main.py`        |
| `database` | `database` | `Dockerfile` → `database` | `${DB_PORT:-3306}`  | MariaDB, schema created from SQLAlchemy models |
| `adminer`  | `adminer`  | `Dockerfile` → `adminer`  | `${ADMINER_PORT:-8081}` | Database web UI                           |

Useful URLs:

| URL                              | What it is                     |
| -------------------------------- | ------------------------------ |
| <http://localhost/>              | React application (via Nginx)  |
| <http://localhost/docs>          | Swagger UI                     |
| <http://localhost/redoc>         | ReDoc                          |
| <http://localhost/openapi.json>  | OpenAPI schema                 |
| <http://localhost:8081/>         | Adminer (system: `MySQL`, server: `database`) |
| <http://localhost:3000/>         | Frontend container directly    |

Compose profiles are split into separate files:

| File                      | Starts                                    |
| ------------------------- | ----------------------------------------- |
| `docker-compose.yml`      | everything (default)                      |
| `docker-compose.back.yml` | backend + database + adminer + nginx      |
| `docker-compose.front.yml`| frontend + nginx                          |

---

## API

| Method | Path             | Description                                  |
| ------ | ---------------- | -------------------------------------------- |
| `GET`  | `/hello`         | Health check, returns `{"status":200,...}`   |
| `POST` | `/api/v1/users`  | Create a user (`username`, `email`, `password`) |

Example:

```bash
curl -X POST http://localhost/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"username":"john","email":"john@example.com","password":"secret"}'
```

---

## Environment variables

All variables live in `.env` (see `.env.example`).

| Variable               | Default              | Used by            | Description                              |
| ---------------------- | -------------------- | ------------------ | ---------------------------------------- |
| `DB_HOST`              | `localhost`          | backend            | DB host (set to `database` inside Docker) |
| `DB_PORT`              | `3306`               | backend, database  | DB port (container port is always `3306`) |
| `DB_NAME`              | `mydb`               | backend, database  | Database name                            |
| `DB_USER`              | `admin`              | backend, database  | Database user                            |
| `DB_PASS`              | `pass`               | backend, database  | Database password                        |
| `DB_SCHEME`            | `mysql+aiomysql`     | backend            | SQLAlchemy async driver                  |
| `MARIADB_ROOT_PASSWORD`| `12345`              | database           | MariaDB root password                    |
| `APP_PORT`             | `8080`               | fastapi            | Uvicorn port (build arg)                 |
| `ADMINER_PORT`         | `8081`               | adminer            | Adminer host port                        |
| `FRONTEND_PORT`        | `3000`               | frontend           | Frontend host port                       |

> `DB_HOST`/`DB_PORT` are overridden in `docker-compose.yml` so containers always reach the DB by its service name, while the values from `.env` are used for local (non-Docker) runs.

---

## Development

### Backend (local)

```bash
python -m venv .venv
.venv\Scripts\activate          # Windows
poetry env use python
poetry install                  # or: pip install -r requirements.txt
```

Run the API with autoreload (from the repo root, so `PYTHONPATH` resolves `apps`/`database`):

```bash
set PYTHONPATH=%CD%
python -m uvicorn apps.backend.main:app --reload --port 8080
```

### Frontend (local)

```bash
cd apps/frontend
npm install
npm run dev                     # http://localhost:3000, /api proxied to :8080
```

### Build the frontend bundle

```bash
cd apps/frontend
npm run build                   # -> apps/frontend/dist
```

### Dependencies (Poetry)

```bash
poetry add <package>
poetry install
poetry export --without-hashes -o requirements.txt
```

The same steps are available as make targets:

```bash
make deps          # venv + Poetry + dependencies (full local setup)
make deps-add      # add a dependency: make deps-add DEP=requests
make deps-export   # refresh requirements.txt from poetry.lock
```

### Seed data

Any `*.sql` files placed in `database/dumps/` are executed by the MariaDB container on first initialization (empty DB volume only).

---

## Make targets

```bash
# Docker Compose
make help          # list all targets
make up            # build + start everything
make down          # stop and remove everything (drops volumes)
make logs          # follow logs of all services
make ps            # container status
make restart       # restart all services
make back-up       # backend stack only
make front-up      # frontend stack only

# Dependency control
make venv          # create the .venv virtual environment
make install-poetry # install Poetry (pip install --user poetry)
make poetry-env    # bind Poetry to the project .venv
make deps          # full setup: venv + Poetry + dependencies
make deps-install  # poetry install
make deps-export   # export locked deps to requirements.txt
make deps-add      # add a dependency: make deps-add DEP=requests
make deps-update   # update deps within version constraints
make front-install # npm ci in apps/frontend
```

---

## Project structure

```text
fastapi_react_service/
├── apps/
│   ├── backend/                     # FastAPI application
│   │   ├── main.py                  # app entry point: FastAPI app, lifespan (init_db), /hello
│   │   ├── api/
│   │   │   └── v1/
│   │   │       ├── __init__.py      # api_router with /api/v1 prefix
│   │   │       └── user.py          # POST /users endpoint (create user)
│   │   └── schemas/
│   │       └── user.py              # Pydantic request/response models
│   └── frontend/                    # React + Vite application
│       ├── index.html               # SPA entry, mounts /src/main.jsx
│       ├── package.json             # npm scripts and dependencies
│       ├── package-lock.json        # locked dependency tree (used by `npm ci`)
│       ├── vite.config.js           # Vite config, dev proxy to the backend
│       └── src/
│           ├── main.jsx             # React bootstrap (createRoot)
│           ├── App.jsx              # UI: backend status, "add user" form
│           └── index.css            # styles
├── database/                        # DB layer, imported by the backend as `database`
│   ├── __init__.py                  # re-exports engine / get_db / init_db / models
│   ├── db_engine.py                 # async engine, session factory, init_db (create_all)
│   ├── dumps/                       # *.sql seed files (executed on first DB init)
│   └── models/
│       ├── base.py                  # DeclarativeBase and int_pk type alias
│       └── user.py                  # UserModel (users table)
├── nginx/                           # Nginx configs
│   ├── nginx.conf                   # main config, mounted into the nginx container
│   ├── nginx.back.conf              # backend-only profile (proxies to `fastapi`)
│   └── nginx.front.conf             # frontend-only profile (proxies to `frontend`)
├── .dockerignore                    # files excluded from the Docker build context
├── .env                             # runtime configuration (not committed)
├── .env.example                     # template for `.env`
├── Dockerfile                       # multi-stage: fastapi / frontend / database / adminer / nginx
├── docker-compose.yml               # full stack (5 services)
├── docker-compose.back.yml          # backend-only stack
├── docker-compose.front.yml         # frontend-only stack
├── Makefile                         # shortcuts for Docker Compose workflows
├── pyproject.toml                   # Poetry project and dependencies
├── poetry.lock                      # locked Python dependencies
├── requirements.txt                 # exported deps, installed in the Docker image
└── README.md                        # this file
```
