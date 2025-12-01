# FIAP Pós-Tech - Ambiente de Desenvolvimento de Microserviços

Este repositório contém a orquestração completa do ambiente de desenvolvimento local para os microserviços FIAP Pós-Tech, facilitando a execução integrada dos serviços usando Docker Compose e automação via Makefile.

## 🏗️ Arquitetura de Microserviços

O sistema é composto por **três serviços independentes**, cada um com seu próprio banco de dados, seguindo os princípios de arquitetura de microserviços:

### Serviços

1. **fiap-pos-tech-auth** - Serviço de Autenticação
   - Keycloak 23 (Gestão de Identidade e Acesso)
   - PostgreSQL 15 (banco exclusivo do Keycloak)
   - API de Autenticação (Node.js/TypeScript/Express)
   - Porta: 3002 (dev) / 3003 (prod)
   - Keycloak Admin: porta 8080

2. **fiap-pos-tech-api** - API Principal (Write)
   - API de gerenciamento de vendas de veículos
   - PostgreSQL 15 (banco exclusivo)
   - Porta: 3001 (dev) / 3002 (prod)
   - Database porta: 5432

3. **fiap-pos-tech-api-read** - API de Leitura (Read)
   - API read-only para consulta de veículos
   - PostgreSQL 15 (banco exclusivo)
   - Porta: 3003 (dev) / 3004 (prod)
   - Database porta: 5434

### Comunicação Entre Serviços

- **Rede Compartilhada**: `fiap-pos-tech-network` (Docker bridge network)
- **Autenticação**: Todas as APIs validam JWT tokens emitidos pelo Keycloak
- **Isolamento**: Cada serviço possui seu próprio banco de dados
- **Produção**: Em produção, os serviços rodam completamente independentes com suas próprias instâncias de infraestrutura

## 🚀 Quick Start

### Opção 1: Usando o Script Automatizado (Recomendado)

```bash
# 1. Setup inicial
make setup

# 2. Criar rede compartilhada
make network-create

# 3. Iniciar todos os serviços automaticamente
./setup-network.sh
```

O script `setup-network.sh` irá:
- ✅ Criar a rede compartilhada `fiap-pos-tech-network`
- ✅ Iniciar os serviços na ordem correta:
  1. Auth Service (Keycloak + Auth API)
  2. Main API (após Keycloak estar pronto)
  3. Read API
- ✅ Aguardar os health checks necessários
- ✅ Exibir URLs de acesso

### Opção 2: Usando o Makefile

```bash
# 1. Setup completo
make setup

# 2. Criar rede compartilhada
make network-create

# 3. Iniciar serviços individualmente (na ordem)
make up-auth        # Auth + Keycloak
sleep 60            # Aguardar Keycloak
make up-api         # Main API
make up-api-read    # Read API

# 4. Verificar saúde
make health-all

# 5. Acessar URLs
make urls
```

### Opção 3: Execução Individual de Cada Serviço

Cada serviço pode ser executado de forma completamente independente:

```bash
# Auth Service
cd fiap-pos-tech-auth
docker compose --profile dev up -d

# Main API
cd fiap-pos-tech-api
docker compose --profile dev up -d

# Read API
cd fiap-pos-tech-api-read
docker compose --profile dev up -d
```

## 📋 Componentes do Sistema

### Bancos de Dados

Cada serviço possui seu próprio banco de dados PostgreSQL 15:

| Serviço | Database | User | Porta | Volume |
|---------|----------|------|-------|---------|
| **Auth (Keycloak)** | `keycloak` | `keycloak` | Interno | `keycloak_postgres_data` |
| **Main API** | `fiap_pos_tech_db` | `fiap_pos_tech_user` | 5432 | `postgres_api_data` |
| **Read API** | `fiap_read_api_db` | `fiap_read_user` | 5434 | `postgres_read_data` |

### Serviços e Portas

| Serviço | Dev Port | Prod Port | Swagger | Admin |
|---------|----------|-----------|---------|-------|
| **Keycloak** | 8080 | 8080 | - | http://localhost:8080 |
| **Auth API** | 3002 | 3003 | /api-docs | - |
| **Main API** | 3001 | 3002 | /api-docs | - |
| **Read API** | 3003 | 3004 | /api-docs | - |

### Dependências Entre Serviços

```
┌─────────────────┐
│   Keycloak      │ ← Primeira dependência (IdP)
│   (Port 8080)   │
└────────┬────────┘
         │
         ├──────────────┐
         │              │
         ▼              ▼
┌─────────────┐  ┌─────────────┐
│  Auth API   │  │  Main API   │
│  (3002)     │  │  (3001)     │
└─────────────┘  └──────┬──────┘
                        │
                        ▼
                 ┌─────────────┐
                 │  Read API   │
                 │  (3003)     │
                 └─────────────┘
```

**Ordem de Inicialização:**
1. Auth Service (Keycloak + Auth API)
2. Main API (depende de Keycloak para autenticação)
3. Read API (opcional, pode iniciar em paralelo com Main API)

## 🛠️ Pré-requisitos

- Docker 20.10+
- Docker Compose v2
- Git
- Make
- curl (para health checks)

## 🎯 Configuração

### Estrutura de Diretórios

```
fiap-pos-tech-development-environment/
├── Makefile                        # Automação de tarefas
├── README.md                       # Este arquivo
├── setup-network.sh               # Script de inicialização automática
├── fiap-pos-tech-auth/            # Serviço de Autenticação
│   ├── docker-compose.yml         # Keycloak + Auth API + PostgreSQL
│   ├── .env                       # Variáveis de ambiente
│   └── ...
├── fiap-pos-tech-api/             # API Principal
│   ├── docker-compose.yml         # Main API + PostgreSQL
│   ├── .env                       # Variáveis de ambiente
│   └── ...
└── fiap-pos-tech-api-read/        # API de Leitura
    ├── docker-compose.yml         # Read API + PostgreSQL
    ├── .env                       # Variáveis de ambiente
    └── ...
```

### Setup Inicial

#### Opção 1: Setup Automático com Makefile (Recomendado)

```bash
# Clone todos os repositórios e configure
make setup
```

Este comando irá:
1. ✅ Clonar `fiap-pos-tech-auth`, `fiap-pos-tech-api` e `fiap-pos-tech-api-read`
2. ✅ Criar arquivos `.env` em cada serviço (a partir de `.env.example`)
3. ✅ Criar a rede compartilhada `fiap-pos-tech-network`
4. ✅ Exibir próximos passos

#### Opção 2: Setup Manual

```bash
# 1. Clone os repositórios
git clone https://github.com/jhonataneduardo/fiap-pos-tech-auth.git
git clone https://github.com/jhonataneduardo/fiap-pos-tech-api.git
git clone https://github.com/jhonataneduardo/fiap-pos-tech-api-read.git

# 2. Configure as variáveis de ambiente em cada serviço
cd fiap-pos-tech-auth && cp .env.example .env && cd ..
cd fiap-pos-tech-api && cp .env.example .env && cd ..
cd fiap-pos-tech-api-read && cp .env.example .env && cd ..

# 3. Crie a rede compartilhada
docker network create fiap-pos-tech-network
```

### Configuração de Variáveis de Ambiente

Cada serviço possui seu próprio arquivo `.env`. Revise e ajuste conforme necessário:

#### fiap-pos-tech-auth/.env

```env
# Keycloak Database
KEYCLOAK_DB_NAME=keycloak
KEYCLOAK_DB_USER=keycloak
KEYCLOAK_DB_PASSWORD=keycloak_password

# Keycloak Admin
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=admin
KEYCLOAK_PORT=8080

# Keycloak Configuration
KEYCLOAK_REALM=fiap-pos-tech
KEYCLOAK_CLIENT_ID=pos-tech-api
KEYCLOAK_CLIENT_SECRET=your_client_secret

# Auth Service
DEV_PORT=3002
PRD_PORT=3003
```

#### fiap-pos-tech-api/.env

```env
# Database
DB_NAME=fiap_pos_tech_db
DB_USER=fiap_pos_tech_user
DB_PASSWORD=fiap_pos_tech_password
DB_PORT=5432

# Service Ports
DEV_PORT=3001
PRD_PORT=3002

# Keycloak (for JWT validation)
KEYCLOAK_URL=http://fiap-keycloak:8080
KEYCLOAK_REALM=fiap-pos-tech
KEYCLOAK_CLIENT_ID=pos-tech-api

# Webhook
WEBHOOK_SECRET=your_webhook_secret_key
```

#### fiap-pos-tech-api-read/.env

```env
# Database
DB_NAME=fiap_read_api_db
DB_USER=fiap_read_user
DB_PASSWORD=fiap_read_password
DB_PORT=5434

# Service Ports
DEV_PORT=3003
PRD_PORT=3004

# Keycloak (for JWT validation)
KEYCLOAK_URL=http://fiap-keycloak:8080
KEYCLOAK_REALM=fiap-pos-tech
KEYCLOAK_CLIENT_ID=pos-tech-api
```

## 📖 Comandos do Makefile

O Makefile oferece comandos organizados por categoria para facilitar o gerenciamento dos microserviços.

### 💡 Ajuda

```bash
make help          # Exibe todos os comandos disponíveis com descrições
```

### 🛠️ Setup e Configuração

```bash
make clone         # Clona todos os repositórios (auth, api, api-read)
make check-env     # Verifica/cria arquivos .env em todos os serviços
make setup         # Setup completo (clone + env + network)
```

### 🌐 Gerenciamento de Rede

```bash
make network-create   # Cria rede compartilhada fiap-pos-tech-network
make network-remove   # Remove a rede compartilhada
make network-status   # Exibe informações da rede e containers conectados
```

### 🔐 Auth Service (fiap-pos-tech-auth)

```bash
make setup-auth    # Build do serviço de autenticação
make up-auth       # Inicia Keycloak + Auth API
make down-auth     # Para o serviço de autenticação
make logs-auth     # Exibe logs do Auth service
make shell-auth    # Acessa shell do container Auth
make build-auth    # Build do serviço
make rebuild-auth  # Rebuild completo (sem cache)
```

### 🗄️ Main API Service (fiap-pos-tech-api)

```bash
make setup-api     # Build da API principal
make up-api        # Inicia Main API + PostgreSQL
make down-api      # Para a API principal
make logs-api      # Exibe logs da Main API
make shell-api     # Acessa shell do container da API
make build-api     # Build do serviço
make rebuild-api   # Rebuild completo (sem cache)

# Database Operations
make migrate-api   # Executa migrations do Prisma
make seed-api      # Popula banco com dados de exemplo
make studio-api    # Abre Prisma Studio
make test-api      # Executa testes
```

### 📖 Read API Service (fiap-pos-tech-api-read)

```bash
make setup-api-read    # Build da API de leitura
make up-api-read       # Inicia Read API + PostgreSQL
make down-api-read     # Para a API de leitura
make logs-api-read     # Exibe logs da Read API
make shell-api-read    # Acessa shell do container
make build-api-read    # Build do serviço
make rebuild-api-read  # Rebuild completo (sem cache)
```

### 🎯 Gerenciamento de Todos os Serviços

```bash
make setup-all     # Setup de todos os serviços (build)
make up-all        # Inicia todos os serviços (via setup-network.sh)
make down-all      # Para todos os serviços
make status-all    # Exibe status de todos os containers
make health-all    # Verifica saúde de todos os serviços
```

### 💻 Acesso aos Bancos de Dados

```bash
make shell-db           # PostgreSQL da Main API
make shell-keycloak-db  # PostgreSQL do Keycloak
```

### 🔄 Desenvolvimento

```bash
make pull          # Atualiza código de todos os repositórios (git pull)
make update        # Pull + rebuild de todos os serviços
make urls          # Exibe URLs de todos os serviços
```

### 🧹 Limpeza

```bash
make clean         # Para e remove todos os containers
make reset         # Reset completo (containers + volumes + network)
```

## 🚦 Uso e Fluxos de Trabalho

### 🎯 Fluxo Completo: Do Zero ao Ambiente Rodando

Este é o fluxo recomendado para inicializar todo o ambiente pela primeira vez:

```bash
# 1. Clone e configure tudo
make setup
# Isso vai:
# - Clonar os 3 repositórios
# - Criar arquivos .env
# - Criar a rede compartilhada

# 2. (Opcional) Revise os arquivos .env de cada serviço
# fiap-pos-tech-auth/.env
# fiap-pos-tech-api/.env
# fiap-pos-tech-api-read/.env

# 3. Build de todos os serviços
make setup-all

# 4. Inicie tudo automaticamente
./setup-network.sh
# OU use os comandos individuais:
# make up-auth && sleep 60 && make up-api && make up-api-read

# 5. Configure o banco da Main API
make migrate-api
make seed-api

# 6. Verifique a saúde dos serviços
make health-all

# 7. Acesse as URLs
make urls
```

### 🔄 Executando Serviços Individualmente

Cada serviço pode ser executado de forma completamente independente para desenvolvimento focado:

#### Apenas Auth Service

```bash
# Criar rede (se não existir)
make network-create

# Iniciar apenas o Auth
make up-auth

# Verificar logs
make logs-auth

# Parar
make down-auth
```

#### Apenas Main API

```bash
# Pré-requisito: Keycloak deve estar rodando
make up-auth

# Aguardar Keycloak ficar pronto (~60s)
sleep 60

# Iniciar Main API
make up-api

# Setup do banco
make migrate-api
make seed-api

# Verificar
curl http://localhost:3001/health

# Parar (sem derrubar o Auth)
make down-api
```

#### Apenas Read API

```bash
# Pré-requisito: Keycloak deve estar rodando
make up-auth

# Iniciar Read API
make up-api-read

# Verificar
curl http://localhost:3003/api/v1/health

# Parar
make down-api-read
```

### 🌐 Executando com o Script setup-network.sh

O script `setup-network.sh` automatiza a inicialização de todos os serviços na ordem correta:

```bash
# Torna o script executável (apenas primeira vez)
chmod +x setup-network.sh

# Execute
./setup-network.sh
```

O script oferece duas opções:
1. **Automático**: Inicia todos os serviços sequencialmente
2. **Manual**: Apenas cria a rede e exibe os comandos

**O que o script faz:**
1. ✅ Verifica/cria a rede `fiap-pos-tech-network`
2. ✅ Inicia Auth Service (Keycloak + Auth API)
3. ✅ Aguarda 60s para Keycloak inicializar
4. ✅ Inicia Main API
5. ✅ Inicia Read API
6. ✅ Exibe URLs de acesso

### 📊 Monitorando os Serviços

```bash
# Status de todos os containers
make status-all

# Health check de todos os serviços
make health-all

# Logs em tempo real
make logs-auth        # Auth service
make logs-api         # Main API
make logs-api-read    # Read API

# Verificar rede
make network-status
```

### 🔧 Desenvolvimento Dia a Dia

```bash
# Iniciar ambiente de trabalho
make up-all

# Desenvolver... (hot reload ativo nos serviços dev)

# Ver logs enquanto desenvolve
make logs-api         # Terminal 1
make logs-auth        # Terminal 2

# Rodar testes
make test-api

# Finalizar
make down-all
```

### 🔄 Atualizando Código dos Repositórios

```bash
# Atualizar código de todos os repos
make pull

# Atualizar e reconstruir tudo
make update

# Reiniciar serviços após atualização
make down-all
make up-all
```

### 🧹 Limpeza e Reset

```bash
# Parar todos os serviços (mantém volumes)
make down-all

# Reset completo (remove tudo)
make reset
# Isso vai:
# - Parar todos os containers
# - Remover todos os volumes (dados dos bancos)
# - Remover a rede compartilhada

# Após reset, reinicialize
make setup-all
./setup-network.sh
make migrate-api
make seed-api
```

## 🌐 Acessando os Serviços

### URLs Principais

Visualize todas as URLs rapidamente:
```bash
make urls
```

### Endpoints por Serviço

#### 🔐 Auth Service

- **Auth API**: http://localhost:3002
  - Swagger: http://localhost:3002/api-docs
  - Health: http://localhost:3002/health
  
- **Keycloak Admin Console**: http://localhost:8080
  - Usuário: `admin`
  - Senha: `admin`
  - Realm: `fiap-pos-tech`

#### 📡 Main API (Write Operations)

- **API**: http://localhost:3001
  - Swagger: http://localhost:3001/api-docs
  - Health: http://localhost:3001/health
  
- **Endpoints**:
  - `POST /api/v1/customers` - Criar cliente
  - `GET /api/v1/customers` - Listar clientes
  - `POST /api/v1/vehicles` - Criar veículo
  - `GET /api/v1/vehicles` - Listar veículos
  - `PATCH /api/v1/vehicles/:id` - Atualizar veículo
  - `POST /api/v1/sales` - Criar venda
  - `POST /api/v1/sales/webhook` - Webhook de pagamento

#### 📖 Read API (Read-Only Operations)

- **API**: http://localhost:3003
  - Swagger: http://localhost:3003/api-docs
  - Health: http://localhost:3003/api/v1/health
  
- **Endpoints**:
  - `GET /api/v1/vehicles` - Listar todos os veículos
  - `GET /api/v1/vehicles/available` - Veículos disponíveis
  - `GET /api/v1/vehicles/sold` - Veículos vendidos

### 🔑 Autenticação

Todas as rotas das APIs (exceto `/health`) requerem autenticação JWT.

#### 1. Registrar um Usuário

```bash
curl -X POST http://localhost:3002/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "cpf": "12345678901",
    "password": "SenhaForte123",
    "email": "usuario@example.com",
    "firstName": "João",
    "lastName": "Silva"
  }'
```

#### 2. Fazer Login

```bash
curl -X POST http://localhost:3002/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "cpf": "12345678901",
    "password": "SenhaForte123"
  }'
```

Resposta:
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cC...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cC...",
    "expiresIn": 3600,
    "tokenType": "Bearer"
  }
}
```

#### 3. Usar o Token nas Requisições

```bash
# Exemplo: Listar clientes
curl -X GET http://localhost:3001/api/v1/customers \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cC..."

# Exemplo: Listar veículos disponíveis (Read API)
curl -X GET http://localhost:3003/api/v1/vehicles/available \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cC..."
```

#### 4. Renovar Token

```bash
curl -X POST http://localhost:3002/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cC..."
  }'
```

### 🗄️ Acesso aos Bancos de Dados

#### Main API Database

```bash
# Via Makefile
make shell-db

# OU diretamente
cd fiap-pos-tech-api
docker compose exec fiap-pos-tech-api-db \
  psql -U fiap_pos_tech_user -d fiap_pos_tech_db
```

**Conexão Externa:**
- Host: `localhost`
- Port: `5432`
- Database: `fiap_pos_tech_db`
- User: `fiap_pos_tech_user`
- Password: (ver `.env`)

#### Read API Database

```bash
cd fiap-pos-tech-api-read
docker compose exec fiap-pos-tech-api-read-db \
  psql -U fiap_read_user -d fiap_read_api_db
```

**Conexão Externa:**
- Host: `localhost`
- Port: `5434`
- Database: `fiap_read_api_db`
- User: `fiap_read_user`
- Password: (ver `.env`)

#### Keycloak Database

```bash
# Via Makefile
make shell-keycloak-db

# OU diretamente
cd fiap-pos-tech-auth
docker compose exec keycloak-postgres \
  psql -U keycloak -d keycloak
```

**Nota:** O banco do Keycloak é interno e não expõe porta para o host.

## 💻 Desenvolvimento Local

### Modo de Desenvolvimento

Os serviços estão configurados com **hot reload** no modo de desenvolvimento:

```bash
# Iniciar em modo dev (hot reload ativo)
make up-auth        # Auth com hot reload
make up-api         # API com hot reload  
make up-api-read    # Read API com hot reload
```

**Características do modo dev:**
- ✅ **Hot reload**: Mudanças no código refletem automaticamente
- ✅ **Volumes montados**: Código fonte montado nos containers
- ✅ **Logs em tempo real**: Output direto no terminal
- ✅ **Debugging**: Source maps disponíveis

### Estrutura de Volumes

Cada serviço monta volumes específicos para hot reload:

```yaml
# Auth Service
volumes:
  - ./fiap-pos-tech-auth/src:/app/src

# Main API
volumes:
  - ./fiap-pos-tech-api/src:/app/src
  - ./fiap-pos-tech-api/prisma:/app/prisma

# Read API
volumes:
  - ./fiap-pos-tech-api-read/src:/app/src
  - ./fiap-pos-tech-api-read/prisma:/app/prisma
```

### Trabalhando com Bancos de Dados

#### Main API Database

```bash
# Executar migrations
make migrate-api

# Popular com dados de exemplo
make seed-api

# Abrir Prisma Studio (interface visual)
make studio-api

# Acessar via CLI
make shell-db
```

#### Read API Database

A Read API compartilha estrutura similar à Main API, mas apenas para leitura.

### Executando Testes

```bash
# Main API tests
make test-api

# Ou diretamente no container
cd fiap-pos-tech-api
docker compose exec fiap-pos-tech-api-dev npm test

# Coverage
cd fiap-pos-tech-api
docker compose exec fiap-pos-tech-api-dev npm run test:coverage
```

### Debugging

Para debugging, você pode acessar o shell dos containers:

```bash
# Auth service
make shell-auth

# Main API
make shell-api

# Read API
make shell-api-read

# Dentro do container, você pode:
npm run dev        # Iniciar manualmente
npm test          # Rodar testes
npx prisma studio # Abrir Prisma Studio
```

## 🏭 Ambiente de Produção

### Diferenças entre Dev e Produção

| Aspecto | Desenvolvimento | Produção |
|---------|----------------|----------|
| **Rede** | Compartilhada local (`fiap-pos-tech-network`) | Infraestrutura separada |
| **Bancos** | Docker volumes locais | RDS, CloudSQL, ou similar |
| **Autenticação** | Keycloak local | Keycloak gerenciado/cluster |
| **Comunicação** | Rede Docker | Service mesh, API Gateway |
| **Build** | Hot reload, dev dependencies | Build otimizado, produção |
| **Logs** | Docker logs | Centralizado (CloudWatch, etc) |
| **Secrets** | `.env` files | Secret managers (AWS Secrets, Vault) |

### Executando em Modo Produção Localmente

Para testar builds de produção localmente:

```bash
# Auth Service (produção)
cd fiap-pos-tech-auth
docker compose --profile prd up -d --build
# Acesso: http://localhost:3003

# Main API (produção)
cd fiap-pos-tech-api
docker compose --profile prd up -d --build
# Acesso: http://localhost:3002

# Read API (produção)
cd fiap-pos-tech-api-read
docker compose --profile prd up -d --build
# Acesso: http://localhost:3004
```

**Características do build de produção:**
- ✅ Build otimizado com Webpack
- ✅ Código minificado
- ✅ Sem dev dependencies
- ✅ Variáveis de ambiente via `PRD_PORT`
- ✅ Multi-stage Docker build

### Arquitetura em Produção

Em produção, cada serviço opera de forma completamente independente:

```
┌─────────────────────────────────────────────────────────┐
│                    Load Balancer / API Gateway          │
└────────────┬────────────────────────────┬───────────────┘
             │                            │
     ┌───────▼────────┐          ┌────────▼────────┐
     │  Auth Service  │          │   Main API      │
     │   + Keycloak   │◄─────────┤                 │
     │                │  (JWT)   │                 │
     └───────┬────────┘          └────────┬────────┘
             │                            │
     ┌───────▼────────┐          ┌────────▼────────┐
     │  PostgreSQL    │          │  PostgreSQL     │
     │  (Keycloak)    │          │  (Main API)     │
     └────────────────┘          └─────────────────┘
                                          │
                                  ┌───────▼────────┐
                                  │   Read API     │
                                  │                │
                                  └───────┬────────┘
                                          │
                                  ┌───────▼────────┐
                                  │  PostgreSQL    │
                                  │  (Read API)    │
                                  └────────────────┘
```

**Características:**
- Cada serviço em sua própria infraestrutura
- Bancos de dados gerenciados e isolados
- Comunicação via HTTPS/TLS
- Autenticação centralizada via Keycloak
- Escalabilidade horizontal independente

## 🐛 Troubleshooting

### Problemas Comuns e Soluções

#### ❌ Rede não encontrada

**Erro:**
```
Error response from daemon: network fiap-pos-tech-network not found
```

**Solução:**
```bash
make network-create
```

#### ❌ Porta já em uso

**Erro:**
```
Error starting userland proxy: listen tcp 0.0.0.0:3001: bind: address already in use
```

**Solução:**
```bash
# Identifique o processo usando a porta
lsof -i :3001  # Substitua pelo número da porta

# Mate o processo
kill -9 <PID>

# Ou mude a porta no .env do serviço
# fiap-pos-tech-api/.env
DEV_PORT=3011
```

#### ❌ Keycloak não está pronto

**Erro:**
```
Failed to validate JWT token
```

**Solução:**
```bash
# Verifique se o Keycloak iniciou completamente
make logs-auth

# Aguarde até ver:
# "Keycloak 23.0.7 started in XXXms"

# Ou force restart
make down-auth
make up-auth
sleep 90  # Keycloak demora ~60-90s para ficar pronto
```

#### ❌ Erro de conexão entre serviços

**Erro:**
```
Error: connect ECONNREFUSED 172.18.0.2:8080
```

**Solução:**
```bash
# Verifique se os serviços estão na mesma rede
make network-status

# Verifique os containers
make status-all

# Reinicie os serviços na ordem correta
make down-all
make up-auth
sleep 60
make up-api
make up-api-read
```

#### ❌ Migrations falhando

**Erro:**
```
Error: P1001: Can't reach database server
```

**Solução:**
```bash
# Verifique se o banco está rodando
cd fiap-pos-tech-api
docker compose ps

# Verifique a variável DATABASE_URL no .env
cat .env | grep DATABASE_URL

# Tente recriar o banco
docker compose down -v
docker compose --profile dev up -d
sleep 10
make migrate-api
```

#### ❌ Volumes com permissões incorretas

**Erro:**
```
Error: EACCES: permission denied
```

**Solução:**
```bash
# Dê permissões corretas aos diretórios
sudo chown -R $USER:$USER fiap-pos-tech-api/
sudo chown -R $USER:$USER fiap-pos-tech-auth/
sudo chown -R $USER:$USER fiap-pos-tech-api-read/

# Ou reconstrua os containers
make rebuild-api
make rebuild-auth
make rebuild-api-read
```

#### ❌ Token JWT não é validado pelas APIs (INVALID_TOKEN)

**Sintomas:**
- Requisições retornam 401 Unauthorized
- Erro: `"Token malformado ou inválido"` ou `"INVALID_TOKEN"`
- Token foi gerado com sucesso pelo Auth Service
- Mesmo tokens recém-gerados não funcionam

**Causa Raiz:**
As APIs (`fiap-pos-tech-api` e `fiap-pos-tech-api-read`) não conseguem validar os tokens JWT porque não conseguem acessar o endpoint JWKS do Keycloak para obter as chaves públicas necessárias para verificar a assinatura do token.

**Diagnóstico Passo a Passo:**

**1. Verificar se Keycloak está rodando e acessível:**
```bash
# Verificar se container está rodando
docker ps | grep keycloak

# Testar health endpoint
curl http://localhost:8080/health/ready

# Testar JWKS endpoint (chaves públicas)
curl http://localhost:8080/realms/fiap-pos-tech/protocol/openid-connect/certs
# Deve retornar JSON com "keys": [...]
```

**2. Verificar conectividade de dentro das APIs:**
```bash
# Testar de dentro da Main API
docker exec fiap-pos-tech-api-dev curl -s http://fiap-keycloak:8080/health/ready

# Testar JWKS de dentro da Main API
docker exec fiap-pos-tech-api-dev \
  curl -s http://fiap-keycloak:8080/realms/fiap-pos-tech/protocol/openid-connect/certs

# Testar de dentro da Read API
docker exec fiap-pos-tech-api-read-dev curl -s http://fiap-keycloak:8080/health/ready

# Se retornar erro ou vazio, há problema de conectividade
```

**3. Verificar configurações de KEYCLOAK_URL:**
```bash
# Main API - DEVE usar nome do container Docker
cat fiap-pos-tech-api/.env | grep KEYCLOAK

# Esperado:
# KEYCLOAK_URL=http://fiap-keycloak:8080
# KEYCLOAK_REALM=fiap-pos-tech
# KEYCLOAK_CLIENT_ID=pos-tech-api

# Read API - DEVE usar nome do container Docker
cat fiap-pos-tech-api-read/.env | grep KEYCLOAK

# Esperado:
# KEYCLOAK_URL=http://fiap-keycloak:8080
# KEYCLOAK_REALM=fiap-pos-tech
# KEYCLOAK_CLIENT_ID=pos-tech-api
```

**4. Verificar se todos estão na mesma rede Docker:**
```bash
# Verificar rede
make network-status

# OU mais detalhado:
docker network inspect fiap-pos-tech-network | grep -A 5 "Containers"

# DEVE listar TODOS estes containers:
# - fiap-keycloak
# - fiap-pos-tech-api-dev
# - fiap-pos-tech-api-read-dev
# - fiap-pos-tech-auth-dev
# - fiap-pos-tech-api-db
# - fiap-pos-tech-api-read-db
# - keycloak-postgres
```

**5. Verificar logs das APIs para erros:**
```bash
# Logs da Main API (procurar erros de JWKS ou autenticação)
make logs-api | grep -i "error\|jwks\|keycloak\|auth"

# Logs da Read API
make logs-api-read | grep -i "error\|jwks\|keycloak\|auth"

# Procure por erros como:
# - "Error fetching signing key"
# - "ECONNREFUSED"
# - "getaddrinfo ENOTFOUND"
```

**Solução:**

**Opção 1: Reiniciar na ordem correta (Mais Comum)**
```bash
# Parar todos os serviços
make down-all

# Iniciar Auth (Keycloak) primeiro e AGUARDAR
make up-auth
echo "Aguardando Keycloak inicializar completamente (90 segundos)..."
sleep 90

# Verificar se Keycloak está pronto ANTES de continuar
curl http://localhost:8080/health/ready
curl http://localhost:8080/realms/fiap-pos-tech/protocol/openid-connect/certs

# Se os comandos acima funcionaram, continue:
make up-api
make up-api-read

# Aguardar APIs inicializarem
sleep 10
```

**Opção 2: Usar o script automatizado**
```bash
make down-all
./setup-network.sh
# Escolha opção "s" para iniciar automaticamente
```

**Opção 3: Corrigir configurações e reiniciar**
```bash
# Se KEYCLOAK_URL estiver incorreto, edite os .env:
nano fiap-pos-tech-api/.env
# Altere para: KEYCLOAK_URL=http://fiap-keycloak:8080

nano fiap-pos-tech-api-read/.env
# Altere para: KEYCLOAK_URL=http://fiap-keycloak:8080

# Reinicie as APIs
make down-api
make down-api-read
make up-api
make up-api-read
```

**Teste End-to-End após correção:**
```bash
# 1. Registrar usuário (se ainda não existir)
curl -X POST http://localhost:3002/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "cpf": "12345678901",
    "password": "SenhaForte123",
    "email": "teste@example.com",
    "firstName": "Teste",
    "lastName": "Usuario"
  }'

# 2. Fazer login e capturar o token
TOKEN=$(curl -s -X POST http://localhost:3002/auth/login \
  -H "Content-Type: application/json" \
  -d '{"cpf": "12345678901", "password": "SenhaForte123"}' \
  | jq -r '.data.accessToken')

# 3. Verificar se token foi obtido
echo "Token obtido: ${TOKEN:0:50}..."

# 4. Testar Main API com o token (deve retornar dados, não erro)
curl -X GET http://localhost:3001/api/v1/customers \
  -H "Authorization: Bearer $TOKEN"

# 5. Testar Read API com o token (deve retornar dados, não erro)
curl -X GET http://localhost:3003/api/v1/vehicles \
  -H "Authorization: Bearer $TOKEN"

# Se ambos retornarem JSON com "success": true, o problema foi resolvido!
```

**Checklist de Verificação:**
- [ ] Keycloak está rodando: `docker ps | grep keycloak`
- [ ] Keycloak health OK: `curl http://localhost:8080/health/ready`
- [ ] JWKS acessível: `curl http://localhost:8080/realms/fiap-pos-tech/protocol/openid-connect/certs`
- [ ] APIs conseguem acessar Keycloak internamente (comandos `docker exec` acima)
- [ ] Todos containers na rede: `make network-status`
- [ ] KEYCLOAK_URL correto nos .env: `http://fiap-keycloak:8080`
- [ ] Aguardou 90+ segundos após iniciar Keycloak
- [ ] Token foi testado imediatamente após ser gerado (não expirado)

#### ❌ Token JWT expirado

**Sintomas:**
- Requisições retornam 401 Unauthorized
- Erro: "Token expirado" ou "TokenExpiredError"
- Token funcionou antes mas parou de funcionar

**Solução:**
```bash
# 1. Faça login novamente para obter novo token
curl -X POST http://localhost:3002/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "cpf": "12345678901",
    "password": "SenhaForte123"
  }'

# 2. Ou use o refresh token (válido por 7 dias)
curl -X POST http://localhost:3002/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "seu_refresh_token_aqui"
  }'
```

**Nota:** Tokens de acesso expiram após 1 hora por padrão. Use refresh tokens para renovar sem fazer login novamente.

### Comandos de Diagnóstico

```bash
# Status geral
make status-all

# Health check
make health-all

# Verificar rede
make network-status
docker network inspect fiap-pos-tech-network

# Logs de todos os serviços
make logs-auth       # Terminal 1
make logs-api        # Terminal 2
make logs-api-read   # Terminal 3

# Verificar portas em uso
lsof -i :3001  # Main API
lsof -i :3002  # Auth API
lsof -i :3003  # Read API
lsof -i :8080  # Keycloak
lsof -i :5432  # PostgreSQL Main
lsof -i :5434  # PostgreSQL Read

# Inspecionar containers
docker inspect fiap-pos-tech-api-dev
docker inspect fiap-keycloak
docker inspect fiap-pos-tech-api-read-dev
```

### Reset Completo

Se nada funcionar, faça um reset completo:

```bash
# 1. Pare tudo
make down-all

# 2. Remove volumes e rede
make reset

# 3. Reinicialize
make setup-all

# 4. Suba os serviços
./setup-network.sh

# 5. Configure o banco
make migrate-api
make seed-api

# 6. Verifique
make health-all
```

## 🌐 Rede e Comunicação

### Rede Compartilhada Local

Para desenvolvimento local, todos os serviços compartilham a rede `fiap-pos-tech-network`:

```bash
# Criar rede
make network-create

# Verificar status
make network-status

# Remover rede (quando não houver containers conectados)
make network-remove
```

### Comunicação Interna (Container-to-Container)

Dentro da rede Docker, os serviços se comunicam usando nomes de container:

| Serviço | Nome do Container | URL Interna |
|---------|------------------|-------------|
| Keycloak | `fiap-keycloak` | `http://fiap-keycloak:8080` |
| Auth API (dev) | `fiap-pos-tech-auth-dev` | `http://fiap-pos-tech-auth-dev:3002` |
| Main API (dev) | `fiap-pos-tech-api-dev` | `http://fiap-pos-tech-api-dev:3001` |
| Read API (dev) | `fiap-pos-tech-api-read-dev` | `http://fiap-pos-tech-api-read-dev:3003` |
| Main DB | `fiap-pos-tech-api-db` | `postgresql://fiap-pos-tech-api-db:5432` |
| Read DB | `fiap-pos-tech-api-read-db` | `postgresql://fiap-pos-tech-api-read-db:5432` |

**Exemplo de configuração em `.env`:**
```env
# Em fiap-pos-tech-api/.env
KEYCLOAK_URL=http://fiap-keycloak:8080
DATABASE_URL=postgresql://user:pass@fiap-pos-tech-api-db:5432/db

# Em fiap-pos-tech-api-read/.env
KEYCLOAK_URL=http://fiap-keycloak:8080
DATABASE_URL=postgresql://user:pass@fiap-pos-tech-api-read-db:5432/db
```

### Comunicação Externa (Host-to-Container)

Do host (sua máquina), acesse via `localhost`:

```bash
# Keycloak
curl http://localhost:8080/health/ready

# Auth API
curl http://localhost:3002/health

# Main API
curl http://localhost:3001/health

# Read API
curl http://localhost:3003/api/v1/health

# Bancos de dados
psql -h localhost -p 5432 -U fiap_pos_tech_user -d fiap_pos_tech_db
psql -h localhost -p 5434 -U fiap_read_user -d fiap_read_api_db
```

## 💾 Volumes e Persistência

### Volumes Docker

Cada serviço possui volumes dedicados para persistência de dados:

```bash
# Listar volumes
docker volume ls | grep fiap

# Inspecionar volume
docker volume inspect postgres_api_data
docker volume inspect postgres_read_data
docker volume inspect keycloak_postgres_data

# Backup de um volume
docker run --rm \
  -v postgres_api_data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/api-backup.tar.gz -C /data .

# Restaurar backup
docker run --rm \
  -v postgres_api_data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/api-backup.tar.gz -C /data
```

### Limpeza de Volumes

```bash
# Remover volumes de um serviço específico
cd fiap-pos-tech-api
docker compose down -v

# Remover todos os volumes (CUIDADO: perde todos os dados!)
make reset
```

## 🔧 Comandos Úteis

### Docker Compose Direto

Quando precisar usar Docker Compose diretamente em um serviço:

```bash
# Auth Service
cd fiap-pos-tech-auth
docker compose --profile dev up -d        # Iniciar
docker compose --profile dev down         # Parar
docker compose logs -f                    # Logs
docker compose ps                         # Status
docker compose exec fiap-pos-tech-auth-dev sh  # Shell

# Main API
cd fiap-pos-tech-api
docker compose --profile dev up -d
docker compose exec fiap-pos-tech-api-dev npm run prisma:migrate:dev
docker compose exec fiap-pos-tech-api-dev npm test

# Read API
cd fiap-pos-tech-api-read
docker compose --profile dev up -d
docker compose exec fiap-pos-tech-api-read-dev sh
```

### Acessar Containers

```bash
# Auth service
make shell-auth
# ou
docker exec -it fiap-pos-tech-auth-dev sh

# Main API
make shell-api
# ou
docker exec -it fiap-pos-tech-api-dev sh

# Read API
make shell-api-read
# ou
docker exec -it fiap-pos-tech-api-read-dev sh

# Keycloak
docker exec -it fiap-keycloak bash
```

### Informações do Ambiente

```bash
# Status de todos os containers
make status-all

# Health check
make health-all

# URLs dos serviços
make urls

# Informações da rede
make network-status

# Uso de recursos
docker stats

# Logs específicos
docker logs fiap-keycloak -f
docker logs fiap-pos-tech-api-dev -f
docker logs fiap-pos-tech-auth-dev -f
```

### Gerenciar Serviços Individuais

```bash
# Restart de um serviço específico
cd fiap-pos-tech-api
docker compose restart fiap-pos-tech-api-dev

# Stop de um serviço específico
docker compose stop fiap-pos-tech-api-dev

# Start de um serviço específico
docker compose start fiap-pos-tech-api-dev

# Rebuild de um serviço
docker compose build fiap-pos-tech-api-dev --no-cache
```

## 📝 Fluxo de Trabalho Recomendado

### Primeiro Uso (Setup Inicial)

```bash
# 1. Setup inicial completo
make setup
# Clona repos, cria .env files, cria rede

# 2. (Opcional) Revise arquivos .env
nano fiap-pos-tech-auth/.env
nano fiap-pos-tech-api/.env
nano fiap-pos-tech-api-read/.env

# 3. Build de todos os serviços
make setup-all

# 4. Inicie o ambiente completo
./setup-network.sh
# Escolha opção automática (s)

# 5. Aguarde todos os serviços iniciarem (~90s)

# 6. Configure banco da Main API
make migrate-api
make seed-api

# 7. Verifique saúde
make health-all

# 8. Teste a autenticação
# Registre usuário
curl -X POST http://localhost:3002/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "cpf": "12345678901",
    "password": "SenhaForte123",
    "email": "teste@example.com",
    "firstName": "Teste",
    "lastName": "Usuario"
  }'

# Faça login
curl -X POST http://localhost:3002/auth/login \
  -H "Content-Type: application/json" \
  -d '{"cpf": "12345678901", "password": "SenhaForte123"}'

# 9. Acesse os serviços
make urls
```

### Dia a Dia de Desenvolvimento

```bash
# Manhã: Iniciar ambiente
make up-all
# OU
./setup-network.sh

# Verificar que tudo está OK
make health-all

# Abrir logs em terminais separados (opcional)
# Terminal 1
make logs-auth

# Terminal 2
make logs-api

# Terminal 3
make logs-api-read

# Desenvolver... (hot reload ativo)
# Edite arquivos em src/ dos serviços

# Rodar testes durante desenvolvimento
make test-api

# Fim do dia: Parar ambiente
make down-all
```

### Trabalhando em um Serviço Específico

Se você está focado apenas em um serviço:

```bash
# Exemplo: Trabalhar apenas na Main API

# 1. Garanta que Auth está rodando (dependência)
make up-auth
sleep 60  # Aguardar Keycloak

# 2. Inicie apenas a Main API
make up-api

# 3. Configure/teste
make migrate-api
make seed-api
make test-api

# 4. Ver logs
make logs-api

# 5. Ao finalizar
make down-api
# (Deixe auth rodando se for usar novamente)
```

### Atualizando Código

```bash
# Atualizar todos os repositórios
make pull

# Rebuild apenas o que mudou
make rebuild-api        # Se mudou a API
make rebuild-auth       # Se mudou o Auth
make rebuild-api-read   # Se mudou a Read API

# Reiniciar serviços
make down-all
make up-all
```

### Resetando o Ambiente

```bash
# Reset suave (para e reinicia)
make down-all
make up-all

# Reset completo (remove volumes e dados)
make reset

# Após reset completo, reinicialize
make setup-all
./setup-network.sh
make migrate-api
make seed-api
```

### Testando Build de Produção

```bash
# Parar serviços de dev
make down-all

# Testar builds de produção
cd fiap-pos-tech-auth
docker compose --profile prd up -d --build

sleep 60

cd ../fiap-pos-tech-api
docker compose --profile prd up -d --build

cd ../fiap-pos-tech-api-read
docker compose --profile prd up -d --build

# Testar
curl http://localhost:3003/health  # Auth prod
curl http://localhost:3002/health  # API prod
curl http://localhost:3004/api/v1/health  # Read prod

# Voltar para dev
cd ..
make down-all
make up-all
```

## 📚 Documentação Adicional

### Repositórios Individuais

Cada serviço possui sua própria documentação detalhada:

- **[fiap-pos-tech-auth](https://github.com/jhonataneduardo/fiap-pos-tech-auth)** - Serviço de Autenticação
  - Integração com Keycloak
  - Gestão de usuários e tokens JWT
  - API de autenticação

- **[fiap-pos-tech-api](https://github.com/jhonataneduardo/fiap-pos-tech-api)** - API Principal
  - CRUD de clientes e veículos
  - Gestão de vendas
  - Webhooks de pagamento
  - CI/CD com GitHub Actions

- **[fiap-pos-tech-api-read](https://github.com/jhonataneduardo/fiap-pos-tech-api-read)** - API de Leitura
  - Consultas read-only
  - Listagem de veículos
  - Segregação de responsabilidades

### Tecnologias Utilizadas

#### Backend
- **Runtime**: Node.js 22
- **Linguagem**: TypeScript
- **Framework Web**: Express.js
- **ORM**: Prisma
- **Autenticação**: Keycloak (OAuth2/OpenID Connect)
- **Validação**: class-validator, class-transformer
- **Testes**: Jest
- **Documentação API**: Swagger/OpenAPI

#### Infraestrutura
- **Containerização**: Docker, Docker Compose
- **Banco de Dados**: PostgreSQL 15
- **Identity Provider**: Keycloak 23
- **Orquestração**: Kubernetes (produção)
- **CI/CD**: GitHub Actions

#### Arquitetura
- **Padrão Arquitetural**: Clean Architecture
- **Domain Design**: DDD (Domain-Driven Design)
- **Patterns**: Repository, Use Case, Dependency Injection
- **Microserviços**: Serviços independentes com bancos isolados

### Links Úteis

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Domain-Driven Design](https://martinfowler.com/bliki/DomainDrivenDesign.html)
- [Microservices Pattern](https://microservices.io/)
- [Prisma Documentation](https://www.prisma.io/docs)
- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [Docker Documentation](https://docs.docker.com/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)

### Convenções de Commit

Os projetos seguem **Conventional Commits** para versionamento semântico:

```bash
feat: nova funcionalidade (MINOR)
fix: correção de bug (PATCH)
docs: documentação
style: formatação
refactor: refatoração (PATCH)
perf: performance (PATCH)
test: testes
build: build/deps (PATCH)
ci: CI/CD
chore: manutenção
```

Exemplo:
```bash
git commit -m "feat: adiciona endpoint de listagem de vendas"
git commit -m "fix: corrige validação de CPF"
git commit -m "docs: atualiza README com instruções de deploy"
```

## 🆘 Suporte e Debugging

### Comandos de Diagnóstico Rápido

```bash
# Visão geral completa
make status-all     # Status de todos os containers
make health-all     # Health de todos os serviços
make network-status # Info da rede e containers conectados

# Logs em tempo real
make logs-auth
make logs-api
make logs-api-read

# Inspecionar containers
docker inspect fiap-keycloak
docker inspect fiap-pos-tech-api-dev
docker inspect fiap-pos-tech-auth-dev
docker inspect fiap-pos-tech-api-read-dev

# Ver uso de recursos
docker stats
```

### Checklist de Verificação

Quando algo não funcionar, verifique nesta ordem:

1. **Rede existe?**
   ```bash
   make network-status
   # Se não, crie: make network-create
   ```

2. **Containers estão rodando?**
   ```bash
   make status-all
   ```

3. **Keycloak está pronto?**
   ```bash
   curl -s http://localhost:8080/health/ready
   # Deve retornar 200 OK
   ```

4. **Serviços estão saudáveis?**
   ```bash
   make health-all
   ```

5. **Portas estão corretas?**
   ```bash
   make urls
   ```

6. **Variáveis de ambiente corretas?**
   ```bash
   cat fiap-pos-tech-auth/.env
   cat fiap-pos-tech-api/.env
   cat fiap-pos-tech-api-read/.env
   ```

### Logs Detalhados

Para debug profundo, acesse logs com timestamps:

```bash
# Com timestamps
docker logs fiap-keycloak --timestamps

# Últimas 100 linhas
docker logs fiap-pos-tech-api-dev --tail 100

# Desde timestamp específico
docker logs fiap-pos-tech-api-dev --since 2024-01-01T00:00:00

# Follow com grep
docker logs -f fiap-pos-tech-api-dev | grep ERROR
```

### Problemas com Banco de Dados

```bash
# Verificar conexão
cd fiap-pos-tech-api
docker compose exec fiap-pos-tech-api-db pg_isready

# Conectar ao banco
make shell-db

# Dentro do PostgreSQL:
\l              # Listar databases
\dt             # Listar tabelas
\d customers    # Descrever tabela
SELECT * FROM customers LIMIT 5;

# Ver migrations aplicadas
SELECT * FROM _prisma_migrations;
```

### Performance e Recursos

```bash
# Uso de CPU/Memória em tempo real
docker stats

# Espaço em disco usado por volumes
docker system df -v

# Limpar recursos não utilizados
docker system prune -a --volumes
# ⚠️ CUIDADO: Remove TUDO não utilizado
```

### FAQ - Perguntas Frequentes

#### 🔧 Configuração e Setup

**Q: Qual a ordem correta para iniciar os serviços?**
A: Auth (Keycloak) → Main API → Read API. Use `./setup-network.sh` para automático.

**Q: Por que o Keycloak demora tanto para iniciar?**
A: Keycloak leva ~60-90s para inicializar completamente, especialmente na primeira vez.

**Q: Como limpo tudo e começo do zero?**
A: Execute `make reset` e depois `make setup-all && ./setup-network.sh`

**Q: Os serviços compartilham o mesmo banco em produção?**
A: Não! Cada serviço tem seu banco independente, tanto em dev quanto em produção.

#### 🔐 Autenticação e JWT

**Q: Estou recebendo "Token malformado ou inválido" nas APIs. O que fazer?**
A: Este é um problema comum de conectividade. Siga estes passos:

```bash
# 1. Verifique se o Keycloak está rodando
docker ps | grep keycloak

# 2. Teste conectividade INTERNA (dentro do container da API)
docker exec -it fiap-pos-tech-api-dev sh -c \
  "apk add curl && curl -s http://fiap-keycloak:8080/realms/fiap-pos-tech/protocol/openid-connect/certs"

# 3. Se falhar, reinicie na ordem correta
make down-all
./setup-network.sh  # Escolha opção automática (s)

# 4. Aguarde 90 segundos e teste novamente
```

**Causa raiz**: As APIs não conseguem acessar o endpoint JWKS do Keycloak para validar tokens.

**Q: Meu token JWT expirou. Como gerar um novo?**
A: Faça login novamente na API de autenticação:

```bash
curl -X POST http://localhost:3002/auth/login \
  -H "Content-Type: application/json" \
  -d '{"cpf": "SEU_CPF", "password": "SUA_SENHA"}'
```

Tokens JWT têm duração de 1 hora por padrão.

**Q: Como testo se a validação JWT está funcionando?**
A: Use este fluxo completo:

```bash
# 1. Obtenha um token
TOKEN=$(curl -s -X POST http://localhost:3002/auth/login \
  -H "Content-Type: application/json" \
  -d '{"cpf": "12345678901", "password": "SenhaForte123"}' \
  | jq -r '.access_token')

# 2. Teste na Main API
curl -i http://localhost:3000/api/vehicles/sales \
  -H "Authorization: Bearer $TOKEN"

# 3. Teste na Read API
curl -i http://localhost:3001/api/vehicles \
  -H "Authorization: Bearer $TOKEN"

# 4. Se ambos retornarem 200, está funcionando!
```

#### 🚀 Desenvolvimento

**Q: Posso rodar apenas um serviço?**
A: Sim, mas o Auth (Keycloak) é dependência obrigatória para autenticação JWT.

**Q: Como atualizo as dependências dos serviços?**
A: Entre no container (`make shell-api`) e execute `npm install` ou rebuilde com `make rebuild-api`

**Q: Posso usar outro banco além do PostgreSQL?**
A: Sim, ajustando o Prisma schema, mas PostgreSQL é o padrão recomendado.

**Q: Como faço backup dos dados?**
A: Use `docker run` com volumes montados (veja seção "Volumes e Persistência")

### Obtendo Ajuda

Se os problemas persistirem:

1. **Verifique os logs detalhados**: `make logs-<service>`
2. **Consulte a documentação do serviço específico** nos repositórios individuais
3. **Execute diagnóstico completo**:
   ```bash
   make status-all
   make health-all
   make network-status
   docker ps -a
   docker network ls
   docker volume ls
   ```
4. **Reset completo como último recurso**: `make reset`

## 📄 Licença

MIT License - FIAP Pós-Tech

---

**Desenvolvido como parte do Tech Challenge do curso de Pós-Graduação em Arquitetura de Software da FIAP** 🎓

---

## 🎯 Resumo Rápido

```bash
# Setup completo primeira vez
make setup && make setup-all && ./setup-network.sh

# Dia a dia
make up-all          # Iniciar
make health-all      # Verificar
make down-all        # Parar

# Desenvolvimento
make logs-api        # Logs
make test-api        # Testes
make migrate-api     # Migrations

# Problemas?
make reset           # Reset completo
```

**Serviços:**
- 🔐 Auth: http://localhost:3002
- 📡 Main API: http://localhost:3001
- 📖 Read API: http://localhost:3003
- 🔑 Keycloak: http://localhost:8080

**Comandos Essenciais:**
- `make help` - Lista todos os comandos
- `make urls` - URLs dos serviços
- `make health-all` - Verifica saúde
- `make status-all` - Status dos containers

---

**Dúvidas?** Consulte as seções específicas acima ou a documentação dos repositórios individuais.
