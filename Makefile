.PHONY: help clone setup up down build logs clean reset restart status health check-env \
	network-create network-remove network-status \
	setup-auth up-auth down-auth logs-auth shell-auth build-auth rebuild-auth \
	setup-api up-api down-api logs-api shell-api build-api rebuild-api migrate-api seed-api studio-api test-api \
	setup-api-sale up-api-sale down-api-sale logs-api-sale shell-api-sale build-api-sale rebuild-api-sale \
	setup-all up-all down-all logs-all status-all health-all \
	shell-db shell-keycloak-db

# Colors for terminal output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Repository URLs
API_REPO := https://github.com/jhonataneduardo/fiap-pos-tech-api.git
API_SALE_REPO := https://github.com/jhonataneduardo/fiap-pos-tech-api-sale.git
AUTH_REPO := https://github.com/jhonataneduardo/fiap-pos-tech-auth.git

# Directories
API_DIR := fiap-pos-tech-api
API_SALE_DIR := fiap-pos-tech-api-sale
AUTH_DIR := fiap-pos-tech-auth

# Network name
NETWORK_NAME := fiap-pos-tech-network

# Docker Compose command (v2 uses "docker compose", v1 uses "$(DOCKER_COMPOSE)")
DOCKER_COMPOSE := docker compose

# Default target
.DEFAULT_GOAL := help

##@ General

help: ## 📋 Display this help message
	@echo "$(BLUE)╔══════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║     FIAP Pos-Tech - Microservices Development Environment   ║$(NC)"
	@echo "$(BLUE)╚══════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)🏗️  Arquitetura: Microserviços Independentes$(NC)"
	@echo "   • fiap-pos-tech-auth (Keycloak + Auth Service)"
	@echo "   • fiap-pos-tech-api (Main API + PostgreSQL)"
	@echo "   • fiap-pos-tech-api-sale (Sale API + PostgreSQL)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make $(YELLOW)<target>$(NC)\n\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-25s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(BLUE)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""

##@ Setup

clone: ## 📦 Clone all repositories
	@echo "$(BLUE)🔄 Cloning repositories...$(NC)"
	@if [ -d "$(AUTH_DIR)" ]; then \
		echo "$(YELLOW)⚠️  $(AUTH_DIR) already exists. Skipping clone.$(NC)"; \
	else \
		echo "$(GREEN)📥 Cloning $(AUTH_REPO)...$(NC)"; \
		git clone $(AUTH_REPO) $(AUTH_DIR); \
		echo "$(GREEN)✅ Auth repository cloned successfully!$(NC)"; \
	fi
	@if [ -d "$(API_DIR)" ]; then \
		echo "$(YELLOW)⚠️  $(API_DIR) already exists. Skipping clone.$(NC)"; \
	else \
		echo "$(GREEN)📥 Cloning $(API_REPO)...$(NC)"; \
		git clone $(API_REPO) $(API_DIR); \
		echo "$(GREEN)✅ API repository cloned successfully!$(NC)"; \
	fi
	@if [ -d "$(API_SALE_DIR)" ]; then \
		echo "$(YELLOW)⚠️  $(API_SALE_DIR) already exists. Skipping clone.$(NC)"; \
	else \
		echo "$(GREEN)📥 Cloning $(API_SALE_REPO)...$(NC)"; \
		git clone $(API_SALE_REPO) $(API_SALE_DIR); \
		echo "$(GREEN)✅ API Read repository cloned successfully!$(NC)"; \
	fi
	@echo "$(GREEN)✨ All repositories are ready!$(NC)"

check-env: ## 🔍 Check if .env files exist in all services
	@echo "$(BLUE)🔍 Checking .env files...$(NC)"
	@if [ -d "$(AUTH_DIR)" ] && [ ! -f "$(AUTH_DIR)/.env" ]; then \
		echo "$(YELLOW)💡 Creating $(AUTH_DIR)/.env from .env.example...$(NC)"; \
		cp $(AUTH_DIR)/.env.example $(AUTH_DIR)/.env 2>/dev/null || echo "$(RED)❌ .env.example not found in $(AUTH_DIR)$(NC)"; \
	fi
	@if [ -d "$(API_DIR)" ] && [ ! -f "$(API_DIR)/.env" ]; then \
		echo "$(YELLOW)💡 Creating $(API_DIR)/.env from .env.example...$(NC)"; \
		cp $(API_DIR)/.env.example $(API_DIR)/.env 2>/dev/null || echo "$(RED)❌ .env.example not found in $(API_DIR)$(NC)"; \
	fi
	@if [ -d "$(API_SALE_DIR)" ] && [ ! -f "$(API_SALE_DIR)/.env" ]; then \
		echo "$(YELLOW)💡 Creating $(API_SALE_DIR)/.env from .env.example...$(NC)"; \
		cp $(API_SALE_DIR)/.env.example $(API_SALE_DIR)/.env 2>/dev/null || echo "$(RED)❌ .env.example not found in $(API_SALE_DIR)$(NC)"; \
	fi
	@echo "$(GREEN)✅ Environment files checked!$(NC)"

setup: clone check-env network-create ## 🛠️  Complete setup (clone + env + network)
	@echo "$(BLUE)🚀 Setting up microservices development environment...$(NC)"
	@echo "$(GREEN)✨ Setup completed successfully!$(NC)"
	@echo "$(YELLOW)💡 Next steps:$(NC)"
	@echo "   1. Review .env files in each service directory"
	@echo "   2. Run 'make setup-all' to initialize all services"
	@echo "   3. Or use 'make setup-auth', 'make setup-api', 'make setup-api-sale' individually"
	@echo "   4. Run './setup-network.sh' for automated startup"

##@ Network Management

network-create: ## 🌐 Create shared Docker network
	@echo "$(BLUE)🌐 Creating shared network...$(NC)"
	@docker network inspect $(NETWORK_NAME) >/dev/null 2>&1 || \
		(docker network create $(NETWORK_NAME) && echo "$(GREEN)✅ Network '$(NETWORK_NAME)' created!$(NC)") || \
		echo "$(YELLOW)⚠️  Network '$(NETWORK_NAME)' already exists$(NC)"

network-remove: ## 🗑️  Remove shared Docker network
	@echo "$(RED)🗑️  Removing shared network...$(NC)"
	@docker network rm $(NETWORK_NAME) 2>/dev/null && echo "$(GREEN)✅ Network removed!$(NC)" || \
		echo "$(YELLOW)⚠️  Network not found or still in use$(NC)"

network-status: ## 📊 Show network information
	@echo "$(BLUE)📊 Network Status:$(NC)"
	@docker network inspect $(NETWORK_NAME) 2>/dev/null | grep -A 20 "Containers" || \
		echo "$(RED)❌ Network '$(NETWORK_NAME)' not found$(NC)"

##@ Auth Service (fiap-pos-tech-auth)

setup-auth: ## 🔐 Setup Auth service (build)
	@echo "$(BLUE)🔐 Setting up Auth service...$(NC)"
	@cd $(AUTH_DIR) && $(DOCKER_COMPOSE) build
	@echo "$(GREEN)✅ Auth service ready!$(NC)"

up-auth: network-create ## 🚀 Start Auth service (Keycloak + Auth API)
	@echo "$(BLUE)🚀 Starting Auth service...$(NC)"
	@cd $(AUTH_DIR) && $(DOCKER_COMPOSE) --profile dev up -d
	@echo "$(GREEN)✅ Auth service started!$(NC)"
	@echo "$(YELLOW)💡 Keycloak Admin: http://localhost:8080 (admin/admin)$(NC)"
	@echo "$(YELLOW)💡 Auth API: http://localhost:3002$(NC)"

down-auth: ## 🛑 Stop Auth service
	@echo "$(BLUE)🛑 Stopping Auth service...$(NC)"
	@cd $(AUTH_DIR) && $(DOCKER_COMPOSE) --profile dev down
	@echo "$(GREEN)✅ Auth service stopped!$(NC)"

logs-auth: ## 📋 Show Auth service logs
	@echo "$(BLUE)📋 Auth service logs:$(NC)"
	@cd $(AUTH_DIR) && $(DOCKER_COMPOSE) logs -f

shell-auth: ## 💻 Access Auth service container shell
	@echo "$(BLUE)💻 Accessing Auth service container...$(NC)"
	@cd $(AUTH_DIR) && $(DOCKER_COMPOSE) exec fiap-pos-tech-auth-dev sh

build-auth: ## 🔨 Build Auth service
	@echo "$(BLUE)🔨 Building Auth service...$(NC)"
	@cd $(AUTH_DIR) && $(DOCKER_COMPOSE) build
	@echo "$(GREEN)✅ Build completed!$(NC)"

rebuild-auth: ## 🔄 Rebuild Auth service from scratch
	@echo "$(BLUE)🔄 Rebuilding Auth service...$(NC)"
	@cd $(AUTH_DIR) && $(DOCKER_COMPOSE) build --no-cache
	@echo "$(GREEN)✅ Rebuild completed!$(NC)"

test-auth: ## 🧪 Run Auth Service tests
	@echo "$(BLUE)🧪 Running Auth Service tests...$(NC)"
	@cd $(AUTH_DIR) && $(DOCKER_COMPOSE) exec fiap-pos-tech-auth-dev npm test

lint-auth: ## 🔍 Run linter on Auth Service
	@echo "$(BLUE)🔍 Running linter...$(NC)"
	@cd $(AUTH_DIR) && $(DOCKER_COMPOSE) exec fiap-pos-tech-auth-dev npm run lint

lint-fix-auth: ## 🔧 Fix linter issues in Auth Service
	@echo "$(BLUE)🔧 Fixing linter issues...$(NC)"
	@cd $(AUTH_DIR) && $(DOCKER_COMPOSE) exec fiap-pos-tech-auth-dev npm run lint:fix

coverage-auth: ## 📊 Generate test coverage for Auth Service
	@echo "$(BLUE)📊 Generating test coverage...$(NC)"
	@cd $(AUTH_DIR) && $(DOCKER_COMPOSE) exec fiap-pos-tech-auth-dev npm run test:coverage

##@ Main API Service (fiap-pos-tech-api)

setup-api: ## 🗄️  Setup Main API service (build)
	@echo "$(BLUE)🗄️  Setting up Main API service...$(NC)"
	@cd $(API_DIR) && $(DOCKER_COMPOSE) build
	@echo "$(GREEN)✅ Main API service ready!$(NC)"

up-api: network-create ## 🚀 Start Main API service (API + PostgreSQL)
	@echo "$(BLUE)🚀 Starting Main API service...$(NC)"
	@cd $(API_DIR) && $(DOCKER_COMPOSE) --profile dev up -d
	@echo "$(GREEN)✅ Main API service started!$(NC)"
	@echo "$(YELLOW)💡 API: http://localhost:3001$(NC)"
	@echo "$(YELLOW)💡 Swagger: http://localhost:3001/api-docs$(NC)"

down-api: ## 🛑 Stop Main API service
	@echo "$(BLUE)🛑 Stopping Main API service...$(NC)"
	@cd $(API_DIR) && $(DOCKER_COMPOSE) --profile dev down
	@echo "$(GREEN)✅ Main API service stopped!$(NC)"

logs-api: ## 📋 Show Main API logs
	@echo "$(BLUE)📋 Main API logs:$(NC)"
	@cd $(API_DIR) && $(DOCKER_COMPOSE) logs -f fiap-pos-tech-api-dev

shell-api: ## 💻 Access Main API container shell
	@echo "$(BLUE)💻 Accessing Main API container...$(NC)"
	@cd $(API_DIR) && $(DOCKER_COMPOSE) exec fiap-pos-tech-api-dev sh

build-api: ## 🔨 Build Main API service
	@echo "$(BLUE)🔨 Building Main API service...$(NC)"
	@cd $(API_DIR) && $(DOCKER_COMPOSE) build
	@echo "$(GREEN)✅ Build completed!$(NC)"

rebuild-api: ## 🔄 Rebuild Main API service from scratch
	@echo "$(BLUE)🔄 Rebuilding Main API service...$(NC)"
	@cd $(API_DIR) && $(DOCKER_COMPOSE) build --no-cache
	@echo "$(GREEN)✅ Rebuild completed!$(NC)"

migrate-api: ## 🗄️  Run database migrations for Main API
	@echo "$(BLUE)🗄️  Running database migrations...$(NC)"
	@cd $(API_DIR) && $(DOCKER_COMPOSE) exec fiap-pos-tech-api-dev npx prisma migrate dev
	@echo "$(GREEN)✅ Migrations completed!$(NC)"

seed-api: ## 🌱 Seed Main API database
	@echo "$(BLUE)🌱 Seeding database...$(NC)"
	@cd $(API_DIR) && $(DOCKER_COMPOSE) exec fiap-pos-tech-api-dev npm run db:seed:dev
	@echo "$(GREEN)✅ Database seeded!$(NC)"

studio-api: ## 🎨 Open Prisma Studio for Main API
	@echo "$(BLUE)🎨 Opening Prisma Studio...$(NC)"
	@cd $(API_DIR) && $(DOCKER_COMPOSE) exec fiap-pos-tech-api-dev npx prisma studio

test-api: ## 🧪 Run Main API tests
	@echo "$(BLUE)🧪 Running tests...$(NC)"
	@cd $(API_DIR) && $(DOCKER_COMPOSE) exec fiap-pos-tech-api-dev npm test

##@ Sale API Service (fiap-pos-tech-api-sale)

setup-api-sale: ## 📖 Setup Sale API service (build)
	@echo "$(BLUE)📖 Setting up Sale API service...$(NC)"
	@cd $(API_SALE_DIR) && $(DOCKER_COMPOSE) build
	@echo "$(GREEN)✅ Sale API service ready!$(NC)"

up-api-sale: network-create ## 🚀 Start Sale API service (API + PostgreSQL)
	@echo "$(BLUE)🚀 Starting Sale API service...$(NC)"
	@cd $(API_SALE_DIR) && $(DOCKER_COMPOSE) --profile dev up -d
	@echo "$(GREEN)✅ Sale API service started!$(NC)"
	@echo "$(YELLOW)💡 Sale API: http://localhost:3003$(NC)"
	@echo "$(YELLOW)💡 Swagger: http://localhost:3003/api-docs$(NC)"

down-api-sale: ## 🛑 Stop Sale API service
	@echo "$(BLUE)🛑 Stopping Sale API service...$(NC)"
	@cd $(API_SALE_DIR) && $(DOCKER_COMPOSE) --profile dev down
	@echo "$(GREEN)✅ Sale API service stopped!$(NC)"

logs-api-sale: ## 📋 Show Sale API logs
	@echo "$(BLUE)📋 Sale API logs:$(NC)"
	@cd $(API_SALE_DIR) && $(DOCKER_COMPOSE) logs -f fiap-pos-tech-api-sale-dev

shell-api-sale: ## 💻 Access Sale API container shell
	@echo "$(BLUE)💻 Accessing Sale API container...$(NC)"
	@cd $(API_SALE_DIR) && $(DOCKER_COMPOSE) exec fiap-pos-tech-api-sale-dev sh

build-api-sale: ## 🔨 Build Sale API service
	@echo "$(BLUE)🔨 Building Sale API service...$(NC)"
	@cd $(API_SALE_DIR) && $(DOCKER_COMPOSE) build
	@echo "$(GREEN)✅ Build completed!$(NC)"

rebuild-api-sale: ## 🔄 Rebuild Sale API service from scratch
	@echo "$(BLUE)🔄 Rebuilding Sale API service...$(NC)"
	@cd $(API_SALE_DIR) && $(DOCKER_COMPOSE) build --no-cache
	@echo "$(GREEN)✅ Rebuild completed!$(NC)"

migrate-api-sale: ## 🗄️  Run database migrations for Sale API
	@echo "$(BLUE)🗄️  Running database migrations...$(NC)"
	@cd $(API_SALE_DIR) && $(DOCKER_COMPOSE) exec fiap-pos-tech-api-sale-dev npx prisma migrate dev
	@echo "$(GREEN)✅ Migrations completed!$(NC)"

studio-api-sale: ## 🎨 Open Prisma Studio for Sale API
	@echo "$(BLUE)🎨 Opening Prisma Studio for Sale API...$(NC)"
	@cd $(API_SALE_DIR) && $(DOCKER_COMPOSE) exec fiap-pos-tech-api-sale-dev npx prisma studio

test-api-sale: ## 🧪 Run Sale API tests
	@echo "$(BLUE)🧪 Running Sale API tests...$(NC)"
	@cd $(API_SALE_DIR) && $(DOCKER_COMPOSE) exec fiap-pos-tech-api-sale-dev npm test

##@ All Services Management

setup-all: network-create setup-auth setup-api setup-api-sale ## 🛠️  Setup all services
	@echo "$(GREEN)✨ All services are set up!$(NC)"

up-all: ## 🚀 Start all services using setup script
	@echo "$(BLUE)🚀 Starting all services...$(NC)"
	@./setup-network.sh
	@echo "$(GREEN)✅ All services started!$(NC)"

down-all: down-api-sale down-api down-auth ## 🛑 Stop all services
	@echo "$(GREEN)✅ All services stopped!$(NC)"

logs-all: ## 📋 Show logs from all services
	@echo "$(BLUE)📋 Opening logs in separate terminals...$(NC)"
	@echo "$(YELLOW)💡 Use 'make logs-auth', 'make logs-api', 'make logs-api-sale' individually$(NC)"

status-all: ## 📊 Show status of all services
	@echo "$(BLUE)╔══════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║                   All Services Status                        ║$(NC)"
	@echo "$(BLUE)╚══════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)Auth Service:$(NC)"
	@cd $(AUTH_DIR) && $(DOCKER_COMPOSE) ps 2>/dev/null || echo "$(RED)Not running$(NC)"
	@echo ""
	@echo "$(YELLOW)Main API Service:$(NC)"
	@cd $(API_DIR) && $(DOCKER_COMPOSE) ps 2>/dev/null || echo "$(RED)Not running$(NC)"
	@echo ""
	@echo "$(YELLOW)Sale API Service:$(NC)"
	@cd $(API_SALE_DIR) && $(DOCKER_COMPOSE) ps 2>/dev/null || echo "$(RED)Not running$(NC)"
	@echo ""

health-all: ## 🏥 Check health of all services
	@echo "$(BLUE)🏥 Checking service health...$(NC)"
	@echo ""
	@echo "$(YELLOW)Keycloak:$(NC)"
	@curl -s http://localhost:8080/health/ready 2>/dev/null && echo "$(GREEN)✅ Ready$(NC)" || echo "$(RED)❌ Not ready$(NC)"
	@echo ""
	@echo "$(YELLOW)Auth Service:$(NC)"
	@curl -s http://localhost:3002/health 2>/dev/null | grep -q "ok" && echo "$(GREEN)✅ Healthy$(NC)" || echo "$(RED)❌ Unhealthy$(NC)"
	@echo ""
	@echo "$(YELLOW)Main API:$(NC)"
	@curl -s http://localhost:3001/api/v1/health 2>/dev/null | grep -q "UP" && echo "$(GREEN)✅ Healthy$(NC)" || echo "$(RED)❌ Unhealthy$(NC)"
	@echo ""
	@echo "$(YELLOW)Sale API:$(NC)"
	@curl -s http://localhost:3003/api/v1/health 2>/dev/null | grep -q "UP" && echo "$(GREEN)✅ Healthy$(NC)" || echo "$(RED)❌ Unhealthy$(NC)"
	@echo ""

##@ Database Access

shell-db: ## 💻 Access Main API database shell
	@echo "$(BLUE)💻 Accessing Main API PostgreSQL...$(NC)"
	@cd $(API_DIR) && $(DOCKER_COMPOSE) exec fiap-pos-tech-api-db psql -U fiap_pos_tech_user -d fiap_pos_tech_db

shell-keycloak-db: ## 💻 Access Keycloak database shell
	@echo "$(BLUE)💻 Accessing Keycloak PostgreSQL...$(NC)"
	@cd $(AUTH_DIR) && $(DOCKER_COMPOSE) exec keycloak-postgres psql -U keycloak -d keycloak

##@ Development

pull: ## 📥 Pull latest changes from all repositories
	@echo "$(BLUE)📥 Pulling latest changes...$(NC)"
	@if [ -d "$(AUTH_DIR)" ]; then \
		echo "$(YELLOW)Updating $(AUTH_DIR)...$(NC)"; \
		cd $(AUTH_DIR) && git pull; \
		echo "$(GREEN)✅ $(AUTH_DIR) updated!$(NC)"; \
	fi
	@if [ -d "$(API_DIR)" ]; then \
		echo "$(YELLOW)Updating $(API_DIR)...$(NC)"; \
		cd $(API_DIR) && git pull; \
		echo "$(GREEN)✅ $(API_DIR) updated!$(NC)"; \
	fi
	@if [ -d "$(API_SALE_DIR)" ]; then \
		echo "$(YELLOW)Updating $(API_SALE_DIR)...$(NC)"; \
		cd $(API_SALE_DIR) && git pull; \
		echo "$(GREEN)✅ $(API_SALE_DIR) updated!$(NC)"; \
	fi

update: pull ## 🔄 Pull changes and rebuild all services
	@echo "$(BLUE)🔄 Updating all services...$(NC)"
	@$(MAKE) rebuild-auth
	@$(MAKE) rebuild-api
	@$(MAKE) rebuild-api-sale
	@echo "$(GREEN)✨ All services updated!$(NC)"

##@ URLs

urls: ## 🌐 Display all service URLs
	@echo "$(BLUE)╔══════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║                     Service URLs                            ║$(NC)"
	@echo "$(BLUE)╚══════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)🔐 Auth Service:$(NC)       http://localhost:3002"
	@echo "$(GREEN)🔐 Auth Swagger:$(NC)       http://localhost:3002/api-docs"
	@echo ""
	@echo "$(GREEN)📡 Main API:$(NC)           http://localhost:3001"
	@echo "$(GREEN)📡 Main API Swagger:$(NC)   http://localhost:3001/api-docs"
	@echo ""
	@echo "$(GREEN)📖 Sale API:$(NC)           http://localhost:3003"
	@echo "$(GREEN)📖 Sale API Swagger:$(NC)   http://localhost:3003/api-docs"
	@echo ""
	@echo "$(GREEN)🔑 Keycloak Admin:$(NC)     http://localhost:8080"
	@echo "   Username: admin"
	@echo "   Password: admin"
	@echo ""
	@echo "$(GREEN)🗄️  PostgreSQL (Main):$(NC)  localhost:5432"
	@echo "   Database: fiap_pos_tech_db"
	@echo "   User: fiap_pos_tech_user"
	@echo ""
	@echo "$(GREEN)🗄️  PostgreSQL (Sale):$(NC)  localhost:5434"
	@echo "   Database: fiap_sale_api_db"
	@echo "   User: fiap_sale_user"
	@echo ""
	@echo "$(GREEN)🗄️  PostgreSQL (KC):$(NC)    localhost:5433 (internal)"
	@echo "   Database: keycloak"
	@echo "   User: keycloak"
	@echo ""

##@ Cleanup

clean: ## 🧹 Stop and remove all containers
	@echo "$(RED)🧹 Cleaning up Docker resources...$(NC)"
	@echo "$(YELLOW)⚠️  This will stop and remove all containers!$(NC)"
	@if bash -c 'read -p "Are you sure? (y/N) " -n 1 -r; echo; [[ $$REPLY =~ ^[Yy]$$ ]]'; then \
		$(MAKE) down-all; \
		echo "$(GREEN)✅ Cleanup completed!$(NC)"; \
	else \
		echo "$(YELLOW)❌ Cleanup cancelled.$(NC)"; \
	fi

reset: ## 🔄 Complete environment reset
	@echo "$(RED)🔄 Resetting complete environment...$(NC)"
	@echo "$(YELLOW)⚠️  This will remove all containers, volumes, and networks!$(NC)"
	@if bash -c 'read -p "Are you sure? (y/N) " -n 1 -r; echo; [[ $$REPLY =~ ^[Yy]$$ ]]'; then \
		cd $(AUTH_DIR) && $(DOCKER_COMPOSE) --profile dev down -v || true; \
		cd ../$(API_DIR) && $(DOCKER_COMPOSE) --profile dev down -v || true; \
		cd ../$(API_SALE_DIR) && $(DOCKER_COMPOSE) --profile dev down -v || true; \
		cd ..; \
		$(MAKE) network-remove; \
		echo "$(GREEN)✅ Environment reset completed!$(NC)"; \
		echo "$(YELLOW)💡 Run 'make setup-all' to reinitialize$(NC)"; \
	else \
		echo "$(YELLOW)❌ Reset cancelled.$(NC)"; \
	fi
