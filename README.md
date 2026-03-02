# fastapi-production-kit-postgresql

![CI](https://github.com/chkechad/fastapi-production-kit-postgresql/actions/workflows/ci.yml/badge.svg)
![Python](https://img.shields.io/badge/python-3.13-blue.svg)
![License](https://img.shields.io/github/license/chkechad/fastapi-production-kit-postgresql)
![Last Commit](https://img.shields.io/github/last-commit/chkechad/fastapi-production-kit-postgresql)
![Coverage](https://codecov.io/gh/chkechad/fastapi-production-kit-postgresql/branch/main/graph/badge.svg)
[![Docs](https://img.shields.io/badge/docs-mkdocs%20material-blue?logo=materialformkdocs)](https://chkechad.github.io/fastapi-production-kit-postgresql/)



> Production-ready FastAPI template inspired by Django's best practices.
> Built with async PostgreSQL, Redis, Celery, JWT auth and a full developer toolchain.

---

## ✅ Features

### Core

- [x] **FastAPI** — modern async Python web framework
- [ ] **SQLModel** — type-safe ORM built on SQLAlchemy + Pydantic
- [ ] **PostgreSQL 17** — primary database with `asyncpg` async driver
- [ ] **Alembic** — database migrations with Django-style sequential naming (`0001_initial.py`)
- [ ] **Pydantic Settings** — environment-based configuration with `.env` support

### Authentication & Security

- [ ] **JWT** — access token + refresh token (via `python-jose`)
- [ ] **bcrypt** — secure password hashing
- [ ] **Rate limiting** — per-route and global via `slowapi` + Redis
- [ ] **CORS** — configurable per environment
- [ ] **Role-based access control** — `USER`, `MODERATOR`, `ADMIN` roles
- [ ] **Object-level permissions** — ??

### Architecture

- [ ] **FastAPI Dependencies**
- [ ] **Generic pagination**
- [ ] **Generic response schemas**
- [ ] **Custom exception hierarchy**
- [ ] **API versioning** — `/api/v1`, `/api/v2` prefix-based routing
- [ ] **Soft delete**

### Middlewares

- [ ] **Request ID**
- [ ] **Timing**
- [ ] **Structured logging**
- [ ] **GZip compression**
- [ ] **Global error handlers**

### Infrastructure

- [ ] **Docker Compose** — app, postgres, redis, pgAdmin, Celery, Flower, Mailhog, Minio
- [ ] **Multi-stage Dockerfile** — `dev` (hot reload) + `prod` (non-root, 4 workers)
- [ ] **Redis 7** — cache, rate limiting, Celery broker
- [ ] **Celery** — async task queue with Beat scheduler
- [ ] **Flower** — Celery monitoring UI
- [ ] **Mailhog** — fake SMTP server for local email testing

### Developer Experience

- [ ] **Makefile** — `make init`, `make migrate`, `make test`, `make check`...
- [ ] **Auto `.env` generation** — `make env` with `openssl rand` secure secrets
- [ ] **Management CLI** — `manage.py` inspired by Django (`runserver`, `migrate`, `seed`...)
- [ ] **Alembic helper** — `make migration m="add user bio"` → `0002_add_user_bio.py`
- [ ] **Typer** — beautiful CLI for management commands and scripts
- [ ] **Pre-commit hooks** — ruff, ruff-format, mypy, ...
- [ ] **Ruff** — linting + formatting (replaces flake8, isort, black)
- [ ] **MyPy strict** — full type checking
- [ ] **Commitizen** — conventional commits + auto changelog
- [ ] **Health checks** — `/health`, `/health/live`, `/health/ready` (K8s ready)
- [ ] **OpenAPI** — custom tags, metadata, disabled in production

### Testing

- [ ] **pytest-asyncio** — async test support
- [ ] **pytest-cov** — coverage with 85% threshold
- [ ] **Transactional fixtures** — each test runs in a rolled-back transaction
- [ ] **AsyncClient** — full HTTP integration tests via `httpx`
- [ ] **User factory** — `make_user(**kwargs)` helper
- [ ] **Auth fixtures** — `auth_client`, `admin_client` ready to use
- [ ] **Hypothesis** — property-based testing
- [ ] **Bandit** — static security analysis
- [ ] **pip-audit** — dependency vulnerability scanning

### Advanced Features

- [ ] **Seed data** — `make seed` / `manage.py loaddata` with JSON fixtures
- [ ] **SQLAdmin panel** — Django-like admin at `/admin`
- [ ] **Cache decorator** — `@cached(ttl=300, key="users:{id}")` with Redis
- [ ] **Feature flags** — DB-backed toggles with Redis cache + admin UI
- [ ] **Audit log** — `user_id`, `action`, `before/after` JSONB, `ip`, `timestamp`
- [ ] **Background tasks** — FastAPI `BackgroundTasks` for lightweight async jobs

---

## 🗂️ Project Structure
---

## ⚡ Quick Start

---

## 🧰 Makefile Commands

---

## 🧪 Testing

---

## 🐳 Production Deployment

---

## 📋 Conventional Commits

---

## 📄 License

MIT
