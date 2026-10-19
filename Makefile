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

.PHONY: back-shell
back-shell: ## Open shell in fastapi container
	$(DC_BACK) exec fastapi /bin/sh

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

.PHONY: front-shell
front-shell: ## Open shell in frontend container
	$(DC_FRONT) exec frontend /bin/sh

.PHONY: front-build
front-build: ## Build frontend images only (no start)
	$(DC_FRONT) build

# --- Всё вместе ---------------------------------------------------------------
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

# --- Очистка ------------------------------------------------------------------
.PHONY: clean
clean: ## Stop everything and remove volumes (WARNING: deletes DB data!)
	$(DC_ALL) down -v

.PHONY: prune
prune: ## Remove unused Docker images, containers and networks
	docker system prune -f

# --- Утилиты ------------------------------------------------------------------
.PHONY: config-back
config-back: ## Validate backend compose config
	$(DC_BACK) config

.PHONY: config-front
config-front: ## Validate frontend compose config
	$(DC_FRONT) config

.PHONY: config-all
config-all: ## Validate both compose configs
	$(DC_ALL) config