# =========================================
# Project configuration
# =========================================
UV          := uv
PYTHON      := $(UV) run python
PRECOMMIT   := $(UV) run pre-commit
PYTEST      := $(UV) run pytest
MKDOCS      := $(UV) run mkdocs
CZ          := $(UV) run cz
PIPAUDIT    := $(UV) run pip-audit
BANDIT      := $(UV) run bandit
DOCKER      := docker compose

SRC := src
TESTS := tests

# =========================================
# Help
# =========================================
.PHONY: help
help:
	@echo "========== Setup =========="
	@echo "make install        Install all dependencies"
	@echo "make env            Generate .env with secure random values"
	@echo "make init           Full init: env + install + docker + migrate"
	@echo ""
	@echo "========== Docker =========="
	@echo "make up             Start all services (dev)"
	@echo "make down           Stop all services"
	@echo "make logs           Follow logs"
	@echo "make ps             Show running services"
	@echo "make restart        Restart app container"
	@echo ""
	@echo "========== Database =========="
	@echo "make migrate        Run Alembic migrations"
	@echo "make migration m=   Create a new migration (m='message')"
	@echo "make db-reset       Drop + recreate DB + migrate"
	@echo ""
	@echo "========== Quality =========="
	@echo "make lint           Run ruff + format"
	@echo "make typecheck      Run mypy"
	@echo "make test           Run pytest + doctest"
	@echo "make coverage       HTML coverage report"
	@echo "make benchmark      Run performance benchmarks"
	@echo ""
	@echo "========== Security =========="
	@echo "make bandit         Code security scan"
	@echo "make security       Dependency audit"
	@echo ""
	@echo "========== Docs =========="
	@echo "make doc-serve      Serve docs"
	@echo "make doc-build      Build docs"
	@echo "make doc-deploy     Deploy docs"
	@echo ""
	@echo "========== Release =========="
	@echo "make release        Bump version"
	@echo ""
	@echo "make check          Full extreme pipeline"
	@echo "make clean          Clean project"
# =========================================
# Setup
# =========================================
.PHONY: install
install:
	$(UV) sync --all-groups
	$(PRECOMMIT) install
	@echo "✅ Dependencies installed + pre-commit hooks set up"

.PHONY: env
env:
	@if [ -f .env ]; then \
		echo "⚠️  .env already exists. Use 'make env-force' to overwrite."; \
		exit 1; \
	fi
	@$(MAKE) _generate_env
	@echo "✅ .env generated with secure random values"

.PHONY: env-force
env-force:
	@$(MAKE) _generate_env
	@echo "✅ .env regenerated (previous values overwritten)"

.PHONY: _generate_env
_generate_env:
	@POSTGRES_PASSWORD=$$(openssl rand -hex 24) && \
	REDIS_PASSWORD=$$(openssl rand -hex 24) && \
	JWT_SECRET=$$(openssl rand -hex 32) && \
	APP_SECRET=$$(openssl rand -hex 32) && \
	PGADMIN_PASSWORD=$$(openssl rand -hex 16) && \
	cat .env.example \
		| sed "s|change-me-in-prod-use-openssl-rand-hex-32|$$APP_SECRET|1" \
		| sed "s|change-me-in-prod-use-openssl-rand-hex-32|$$JWT_SECRET|1" \
		| sed "s|POSTGRES_PASSWORD=postgres|POSTGRES_PASSWORD=$$POSTGRES_PASSWORD|" \
		| sed "s|REDIS_PASSWORD=redis_secret|REDIS_PASSWORD=$$REDIS_PASSWORD|" \
		| sed "s|PGADMIN_PASSWORD=admin|PGADMIN_PASSWORD=$$PGADMIN_PASSWORD|" \
		| sed "s|CELERY_BROKER_URL=redis://:redis_secret|CELERY_BROKER_URL=redis://:$$REDIS_PASSWORD|" \
		| sed "s|CELERY_RESULT_BACKEND=redis://:redis_secret|CELERY_RESULT_BACKEND=redis://:$$REDIS_PASSWORD|" \
		> .env

.PHONY: init
init:
	@echo "🚀 Initializing project..."
	@if [ ! -f .env ]; then \
		$(MAKE) env; \
	else \
		echo "ℹ️  .env already exists, skipping generation"; \
	fi
	$(MAKE) install
	$(MAKE) up-wait
	$(MAKE) migrate
	@echo ""
	@echo "✅✅✅ Project ready!"
	@echo ""
	@echo "  App      → http://localhost:8000"
	@echo "  Docs     → http://localhost:8000/docs"
	@echo "  pgAdmin  → http://localhost:5050"
	@echo "  Flower   → http://localhost:5555"
	@echo "  Mailhog  → http://localhost:8025"
	@echo ""
# =========================================
# Docker
# =========================================
.PHONY: up
up:
	$(DOCKER) up -d --build
	@echo "✅ Services started"

.PHONY: up-wait
up-wait:
	@echo "⏳ Starting services and waiting for postgres..."
	$(DOCKER) up -d --build
	@echo "⏳ Waiting for postgres to be healthy..."
	@until $(DOCKER) exec postgres pg_isready -q; do \
		printf '.'; sleep 3; \
	done
	@echo ""
	@echo "✅ Services ready"

.PHONY: down
down:
	$(DOCKER) down
	@echo "✅ Services stopped"

.PHONY: down-volumes
down-volumes:
	$(DOCKER) down -v
	@echo "✅ Services stopped + volumes deleted"

.PHONY: logs
logs:
	$(DOCKER) logs -f app

.PHONY: logs-all
logs-all:
	$(DOCKER) logs -f

.PHONY: ps
ps:
	$(DOCKER) ps

.PHONY: restart
restart:
	$(DOCKER) restart app
	@echo "✅ App restarted"
# =========================================
# Database / Alembic
# =========================================
.PHONY: migrate
migrate:
	$(DOCKER) exec app uv run alembic upgrade head
	@echo "✅ Migrations applied"

.PHONY: migration
migration:
	@if [ -z "$(m)" ]; then \
		echo "❌ Usage: make migration m='your migration message'"; \
		exit 1; \
	fi
	$(DOCKER) exec app uv run alembic revision --autogenerate -m "$(m)"
	@echo "✅ Migration created"

.PHONY: migrate-down
migrate-down:
	$(DOCKER) exec app uv run alembic downgrade -1
	@echo "✅ Rolled back 1 migration"

.PHONY: db-reset
db-reset:
	@echo "⚠️  This will drop and recreate the database. Press Ctrl+C to cancel."
	@sleep 3
	$(DOCKER) exec app uv run alembic downgrade base
	$(DOCKER) exec app uv run alembic upgrade head
	@echo "✅ Database reset"
# =========================================
# Quality
# =========================================
.PHONY: lint
lint:
	$(PRECOMMIT) run ruff --all-files
	$(PRECOMMIT) run ruff-format --all-files

.PHONY: typecheck
typecheck:
	$(PRECOMMIT) run mypy --all-files

.PHONY: test
test:
	$(PYTEST) tests --cov=. --cov-report=term-missing --doctest-modules

.PHONY: coverage
coverage:
	$(PYTEST) --cov=. --cov-report=html
	@echo "Coverage report → htmlcov/index.html"

.PHONY: benchmark
benchmark:
	$(PYTEST) --benchmark-only

# =========================================
# Security
# =========================================
.PHONY: bandit
bandit:
	$(BANDIT) -q -r $(SRC) -x $(TESTS)

.PHONY: security
security:
	$(PIPAUDIT) --strict

# =========================================
# Documentation
# =========================================
.PHONY: doc-serve
doc-serve:
	$(MKDOCS) serve

.PHONY: doc-build
doc-build:
	$(MKDOCS) build --strict

.PHONY: doc-deploy
doc-deploy:
	$(MKDOCS) gh-deploy --force

# =========================================
# Release
# =========================================
.PHONY: release
release:
	$(CZ) bump
	@echo "Version bumped + changelog updated"

# =========================================
# Master pipeline
# =========================================
.PHONY: check
check: lint typecheck bandit security test
	@echo "✅✅✅✅"

# =========================================
# Cleaning
# =========================================
.PHONY: clean
clean:
	rm -rf __pycache__
	rm -rf .pytest_cache
	rm -rf .mypy_cache
	rm -rf .ruff_cache
	rm -rf .coverage
	rm -rf htmlcov
	rm -rf site
	rm -rf dist
	rm -rf build
	rm -rf .cache/pre-commit
