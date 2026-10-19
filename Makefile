# =============================================================================
# Makefile для управления Docker Compose (backend / frontend)
# =============================================================================

# --- Переменные ---------------------------------------------------------------
COMPOSE_BACK   := docker-compose.back.yml
COMPOSE_FRONT  := docker-compose.front.yml

# Базовые команды
DC_BACK        := docker compose -f $(COMPOSE_BACK)
DC_FRONT       := docker compose -f $(COMPOSE_FRONT)
DC_ALL         := docker compose

# Dependency control
PYTHON         ?= python
VENV           := .venv
VENV_PY        := $(VENV)/Scripts/python.exe
FRONTEND_DIR   := apps/frontend

# --- Справка ------------------------------------------------------------------
.PHONY: help
help: ## Show available commands
	@powershell -NoProfile -Command "Get-Content $(MAKEFILE_LIST) | Select-String '^[a-zA-Z_-]+:.*?## .*$$' | ForEach-Object { $$parts = $$_ -split ':.*?## ', 2; Write-Host ('  {0,-20} {1}' -f $$parts[0], $$parts[1]) }"

# --- Backend ------------------------------------------------------------------
.PHONY: back-up
back-up: ## Build and start backend in background
	$(DC_BACK) up --build -d

.PHONY: back-down
back-down: ## Stop and remove backend containers
	$(DC_BACK) down -v

.PHONY: back-logs
back-logs: ## Show backend logs (follow mode)
	$(DC_BACK) logs -f

.PHONY: back-ps
back-ps: ## Show backend container status
	$(DC_BACK) ps

.PHONY: back-restart
back-restart: ## Restart backend
	$(DC_BACK) restart

.PHONY: back-build
back-build: ## Build backend images only (no start)
	$(DC_BACK) build

# --- Frontend -----------------------------------------------------------------
.PHONY: front-up
front-up: ## Build and start frontend in background
	$(DC_FRONT) up --build -d

.PHONY: front-down
front-down: ## Stop and remove frontend containers
	$(DC_FRONT) down -v

.PHONY: front-logs
front-logs: ## Show frontend logs (follow mode)
	$(DC_FRONT) logs -f

.PHONY: front-ps
front-ps: ## Show frontend container status
	$(DC_FRONT) ps

.PHONY: front-restart
front-restart: ## Restart frontend
	$(DC_FRONT) restart

.PHONY: front-build
front-build: ## Build frontend images only (no start)
	$(DC_FRONT) build

# --- All ---------------------------------------------------------------
.PHONY: up
up: ## Build and start everything (backend + frontend)
	$(DC_ALL) up --build -d

.PHONY: down
down: ## Stop and remove everything
	$(DC_ALL) down -v

.PHONY: logs
logs: ## Show logs for all services
	$(DC_ALL) logs -f

.PHONY: ps
ps: ## Show status of all containers
	$(DC_ALL) ps

.PHONY: restart
restart: ## Restart everything
	$(DC_ALL) restart

# --- Dependency control (venv / Poetry) ---------------------------------------
.PHONY: venv
venv: ## Create the .venv virtual environment
	$(PYTHON) -m venv $(VENV)
	$(VENV_PY) -m pip install --upgrade pip

.PHONY: install-poetry
install-poetry: ## Install Poetry (pip install --user poetry)
	$(PYTHON) -m pip install --user poetry

.PHONY: poetry-env
poetry-env: venv ## Bind Poetry to the project .venv
	poetry env use $(VENV_PY)

.PHONY: deps-install
deps-install: ## Install Python dependencies with Poetry
	poetry install

.PHONY: deps-export
deps-export: ## Export locked dependencies to requirements.txt
	poetry export --without-hashes -o requirements.txt

.PHONY: deps-add
deps-add: ## Add a Python dependency (usage: make deps-add DEP=requests)
	poetry add $(DEP)

.PHONY: deps-update
deps-update: ## Update Python dependencies within version constraints
	poetry update

.PHONY: deps
deps: venv install-poetry poetry-env deps-install ## Full local setup: venv + Poetry + dependencies
	@echo "Python dependencies are ready. Run 'make deps-export' to refresh requirements.txt."

.PHONY: front-install
front-install: ## Install frontend dependencies (npm ci)
	npm --prefix $(FRONTEND_DIR) ci
