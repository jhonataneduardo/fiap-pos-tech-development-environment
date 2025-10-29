.PHONY: help clone setup up down build logs clean reset restart status health check-env shell-api shell-auth shell-db migrate-api seed-api studio-api test-api

# Colors for terminal output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Repository URLs
API_REPO := https://github.com/jhonataneduardo/fiap-pos-tech-api.git
AUTH_REPO := https://github.com/jhonataneduardo/fiap-pos-tech-auth.git

# Directories
API_DIR := fiap-pos-tech-api
AUTH_DIR := fiap-pos-tech-auth

# Docker Compose command (v2 uses "docker compose", v1 uses "$(DOCKER_COMPOSE)")
DOCKER_COMPOSE := docker compose

# Default target
.DEFAULT_GOAL := help

##@ General

help: ## 📋 Display this help message
	@echo "$(BLUE)╔══════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║        FIAP Pos-Tech - Development Environment Setup        ║$(NC)"
	@echo "$(BLUE)╚══════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make $(YELLOW)<target>$(NC)\n\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(BLUE)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""

##@ Setup

clone: ## 📦 Clone API and Auth repositories
	@echo "$(BLUE)🔄 Cloning repositories...$(NC)"
	@if [ -d "$(API_DIR)" ]; then \
		echo "$(YELLOW)⚠️  $(API_DIR) already exists. Skipping clone.$(NC)"; \
	else \
		echo "$(GREEN)📥 Cloning $(API_REPO)...$(NC)"; \
		git clone $(API_REPO) $(API_DIR); \
		echo "$(GREEN)✅ API repository cloned successfully!$(NC)"; \
	fi
	@if [ -d "$(AUTH_DIR)" ]; then \
		echo "$(YELLOW)⚠️  $(AUTH_DIR) already exists. Skipping clone.$(NC)"; \
	else \
		echo "$(GREEN)📥 Cloning $(AUTH_REPO)...$(NC)"; \
		git clone $(AUTH_REPO) $(AUTH_DIR); \
		echo "$(GREEN)✅ Auth repository cloned successfully!$(NC)"; \
	fi
	@echo "$(GREEN)✨ All repositories are ready!$(NC)"

check-env: ## 🔍 Check if .env file exists
	@if [ ! -f .env ]; then \
		echo "$(RED)❌ .env file not found!$(NC)"; \
		echo "$(YELLOW)💡 Creating .env from .env.example...$(NC)"; \
		cp .env.example .env; \
		echo "$(GREEN)✅ .env file created! Please review and update it.$(NC)"; \
	else \
		echo "$(GREEN)✅ .env file found!$(NC)"; \
	fi

setup: clone check-env ## 🛠️  Complete setup (clone + check env + build)
	@echo "$(BLUE)🚀 Setting up development environment...$(NC)"
	@$(MAKE) build
	@echo "$(GREEN)✨ Setup completed successfully!$(NC)"
	@echo "$(YELLOW)💡 Next steps:$(NC)"
	@echo "   1. Review your .env file"
	@echo "   2. Run 'make up' to start the services"
	@echo "   3. Run 'make migrate-api' to setup database"
	@echo "   4. Run 'make seed-api' to populate with sample data"

##@ Docker Operations

up: check-env ## 🚀 Start all services
	@echo "$(BLUE)🚀 Starting containers...$(NC)"
	@$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)✅ Containers are up and running!$(NC)"
	@echo "$(YELLOW)💡 Run 'make logs' to see container logs$(NC)"
	@echo "$(YELLOW)💡 Run 'make status' to check container status$(NC)"

down: ## 🛑 Stop all services
	@echo "$(BLUE)🛑 Stopping containers...$(NC)"
	@$(DOCKER_COMPOSE) down
	@echo "$(GREEN)✅ Containers stopped successfully!$(NC)"

build: check-env ## 🔨 Build all services
	@echo "$(BLUE)🔨 Building services...$(NC)"
	@$(DOCKER_COMPOSE) build
	@echo "$(GREEN)✅ Build completed successfully!$(NC)"

rebuild: ## 🔄 Rebuild all services from scratch
	@echo "$(BLUE)🔄 Rebuilding services from scratch...$(NC)"
	@$(DOCKER_COMPOSE) build --no-cache
	@echo "$(GREEN)✅ Rebuild completed successfully!$(NC)"

restart: ## 🔄 Restart all services
	@echo "$(BLUE)🔄 Restarting containers...$(NC)"
	@$(MAKE) down
	@$(MAKE) up
	@echo "$(GREEN)✅ Containers restarted successfully!$(NC)"

##@ Monitoring

logs: ## 📋 Show logs from all containers
	@echo "$(BLUE)📋 Displaying container logs...$(NC)"
	@$(DOCKER_COMPOSE) logs -f

logs-api: ## 📋 Show API logs
	@echo "$(BLUE)📋 Displaying API logs...$(NC)"
	@$(DOCKER_COMPOSE) logs -f fiap-pos-tech-api

logs-auth: ## 📋 Show Auth logs
	@echo "$(BLUE)📋 Displaying Auth logs...$(NC)"
	@$(DOCKER_COMPOSE) logs -f fiap-pos-tech-auth

logs-db: ## 📋 Show database logs
	@echo "$(BLUE)📋 Displaying database logs...$(NC)"
	@$(DOCKER_COMPOSE) logs -f fiap-pos-tech-db

logs-keycloak: ## 📋 Show Keycloak logs
	@echo "$(BLUE)📋 Displaying Keycloak logs...$(NC)"
	@$(DOCKER_COMPOSE) logs -f keycloak

status: ## 📊 Show status of all containers
	@echo "$(BLUE)📊 Container Status:$(NC)"
	@$(DOCKER_COMPOSE) ps

health: ## 🏥 Check health of all services
	@echo "$(BLUE)🏥 Checking service health...$(NC)"
	@echo ""
	@echo "$(YELLOW)API Service:$(NC)"
	@curl -s http://localhost:3001/health 2>/dev/null | jq '.' || echo "$(RED)❌ API is not responding$(NC)"
	@echo ""
	@echo "$(YELLOW)Auth Service:$(NC)"
	@curl -s http://localhost:3002/health 2>/dev/null | jq '.' || echo "$(RED)❌ Auth is not responding$(NC)"
	@echo ""
	@echo "$(YELLOW)Keycloak:$(NC)"
	@curl -s http://localhost:8080/health/ready 2>/dev/null && echo "$(GREEN)✅ Keycloak is ready$(NC)" || echo "$(RED)❌ Keycloak is not ready$(NC)"

##@ Database Operations

migrate-api: ## 🗄️  Run database migrations for API
	@echo "$(BLUE)🗄️  Running database migrations...$(NC)"
	@$(DOCKER_COMPOSE) exec fiap-pos-tech-api npm run prisma:migrate:dev
	@echo "$(GREEN)✅ Migrations completed successfully!$(NC)"

migrate-deploy-api: ## 🗄️  Deploy migrations to production (API)
	@echo "$(BLUE)🗄️  Deploying migrations...$(NC)"
	@$(DOCKER_COMPOSE) exec fiap-pos-tech-api npm run prisma:migrate:deploy
	@echo "$(GREEN)✅ Migrations deployed successfully!$(NC)"

seed-api: ## 🌱 Seed database with sample data
	@echo "$(BLUE)🌱 Seeding database...$(NC)"
	@$(DOCKER_COMPOSE) exec fiap-pos-tech-api npm run prisma:seed
	@echo "$(GREEN)✅ Database seeded successfully!$(NC)"

studio-api: ## 🎨 Open Prisma Studio
	@echo "$(BLUE)🎨 Opening Prisma Studio...$(NC)"
	@$(DOCKER_COMPOSE) exec fiap-pos-tech-api npm run prisma:studio

##@ Shell Access

shell-api: ## 💻 Access API container shell
	@echo "$(BLUE)💻 Accessing API container shell...$(NC)"
	@$(DOCKER_COMPOSE) exec fiap-pos-tech-api sh

shell-auth: ## 💻 Access Auth container shell
	@echo "$(BLUE)💻 Accessing Auth container shell...$(NC)"
	@$(DOCKER_COMPOSE) exec fiap-pos-tech-auth sh

shell-db: ## 💻 Access database shell
	@echo "$(BLUE)💻 Accessing database shell...$(NC)"
	@$(DOCKER_COMPOSE) exec fiap-pos-tech-db psql -U fiap_pos_tech_user -d fiap_pos_tech_db

shell-keycloak-db: ## 💻 Access Keycloak database shell
	@echo "$(BLUE)💻 Accessing Keycloak database shell...$(NC)"
	@$(DOCKER_COMPOSE) exec keycloak-db psql -U keycloak -d keycloak

##@ Testing

test-api: ## 🧪 Run API tests
	@echo "$(BLUE)🧪 Running API tests...$(NC)"
	@$(DOCKER_COMPOSE) exec fiap-pos-tech-api npm test

test-api-watch: ## 🧪 Run API tests in watch mode
	@echo "$(BLUE)🧪 Running API tests in watch mode...$(NC)"
	@$(DOCKER_COMPOSE) exec fiap-pos-tech-api npm run test:watch

test-api-coverage: ## 📊 Run API tests with coverage
	@echo "$(BLUE)📊 Running API tests with coverage...$(NC)"
	@$(DOCKER_COMPOSE) exec fiap-pos-tech-api npm run test:coverage

##@ Cleanup

clean: ## 🧹 Remove containers, volumes, and images
	@echo "$(RED)🧹 Cleaning up Docker resources...$(NC)"
	@echo "$(YELLOW)⚠️  This will remove all containers, volumes, and images!$(NC)"
	@read -p "Are you sure? (y/N) " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		$(DOCKER_COMPOSE) down -v --rmi all; \
		echo "$(GREEN)✅ Cleanup completed!$(NC)"; \
	else \
		echo "$(YELLOW)❌ Cleanup cancelled.$(NC)"; \
	fi

clean-volumes: ## 🗑️  Remove only Docker volumes
	@echo "$(RED)🗑️  Removing Docker volumes...$(NC)"
	@echo "$(YELLOW)⚠️  This will delete all database data!$(NC)"
	@read -p "Are you sure? (y/N) " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		$(DOCKER_COMPOSE) down -v; \
		echo "$(GREEN)✅ Volumes removed!$(NC)"; \
	else \
		echo "$(YELLOW)❌ Operation cancelled.$(NC)"; \
	fi

reset: ## 🔄 Complete environment reset
	@echo "$(RED)🔄 Resetting complete environment...$(NC)"
	@echo "$(YELLOW)⚠️  This will remove all containers, volumes, and rebuild everything!$(NC)"
	@read -p "Are you sure? (y/N) " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		$(MAKE) down; \
		$(DOCKER_COMPOSE) down -v; \
		$(MAKE) build; \
		$(MAKE) up; \
		echo "$(GREEN)✅ Environment reset completed!$(NC)"; \
		echo "$(YELLOW)💡 Don't forget to run migrations and seed!$(NC)"; \
	else \
		echo "$(YELLOW)❌ Reset cancelled.$(NC)"; \
	fi

##@ Development

pull: ## 📥 Pull latest changes from repositories
	@echo "$(BLUE)📥 Pulling latest changes...$(NC)"
	@if [ -d "$(API_DIR)" ]; then \
		echo "$(YELLOW)Updating $(API_DIR)...$(NC)"; \
		cd $(API_DIR) && git pull; \
		echo "$(GREEN)✅ $(API_DIR) updated!$(NC)"; \
	fi
	@if [ -d "$(AUTH_DIR)" ]; then \
		echo "$(YELLOW)Updating $(AUTH_DIR)...$(NC)"; \
		cd $(AUTH_DIR) && git pull; \
		echo "$(GREEN)✅ $(AUTH_DIR) updated!$(NC)"; \
	fi

update: pull rebuild restart ## 🔄 Pull changes, rebuild and restart
	@echo "$(GREEN)✨ Environment updated successfully!$(NC)"

install-deps: ## 📦 Install dependencies in both services
	@echo "$(BLUE)📦 Installing dependencies...$(NC)"
	@$(DOCKER_COMPOSE) exec fiap-pos-tech-api npm install
	@$(DOCKER_COMPOSE) exec fiap-pos-tech-auth npm install
	@echo "$(GREEN)✅ Dependencies installed!$(NC)"

##@ URLs

urls: ## 🌐 Display all service URLs
	@echo "$(BLUE)╔══════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║                     Service URLs                            ║$(NC)"
	@echo "$(BLUE)╚══════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)📡 API Service:$(NC)         http://localhost:3001"
	@echo "$(GREEN)📡 API Swagger:$(NC)        http://localhost:3001/api-docs"
	@echo ""
	@echo "$(GREEN)🔐 Auth Service:$(NC)       http://localhost:3002"
	@echo "$(GREEN)🔐 Auth Swagger:$(NC)       http://localhost:3002/api-docs"
	@echo ""
	@echo "$(GREEN)🔑 Keycloak Admin:$(NC)     http://localhost:8080"
	@echo "   Username: admin"
	@echo "   Password: admin"
	@echo ""
	@echo "$(GREEN)🗄️  PostgreSQL (API):$(NC)   localhost:5432"
	@echo "   Database: fiap_pos_tech_db"
	@echo "   User: fiap_pos_tech_user"
	@echo ""
	@echo "$(GREEN)🗄️  PostgreSQL (KC):$(NC)    localhost:5433"
	@echo "   Database: keycloak"
	@echo "   User: keycloak"
	@echo ""
