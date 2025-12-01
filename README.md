# FIAP Pós-Tech - Ambiente de Desenvolvimento

Orquestração dos microserviços FIAP Pós-Tech para desenvolvimento local.

## 📦 Serviços

**3 Microserviços Independentes:**

| Serviço | Porta | Descrição | Database |
|---------|-------|-----------|----------|
| **Auth** | 3002 | Keycloak + API de Autenticação | Interno |
| **Main API** | 3001 | Clientes, Veículos e Listagens (Write + Read) | 5432 |
| **Sale API** | 3003 | Vendas e Consultas Avançadas (Read) | 5434 |

## 🚀 Quick Start

### 1. Setup Inicial

```bash
# Clone os repositórios e configure o ambiente
make setup

# Build dos serviços
make setup-all
```

### 2. Inicie os Serviços

```bash
# Opção A: Script automatizado (recomendado)
./setup-network.sh

# Opção B: Manual
make up-auth        # Keycloak + Auth API
sleep 60            # Aguardar Keycloak inicializar
make up-api         # Main API
make up-api-sale    # Sale API
```

### 3. Configure os Bancos de Dados (OBRIGATÓRIO)

```bash
# Main API - Executar migrations
make migrate-api

# Main API - Popular com dados de exemplo
make seed-api

# Sale API - Executar migrations
make migrate-api-sale
```

### 4. Verifique a Saúde

```bash
make health-all
```

### 5. Acesse os Serviços

```bash
make urls
```

**URLs:**
- 🔐 Auth API: http://localhost:3002/api-docs
- 📡 Main API: http://localhost:3001/api-docs
- 📖 Sale API: http://localhost:3003/api-docs
- 🔑 Keycloak Admin: http://localhost:8080 (admin/admin)

## 🔑 Autenticação

Todas as rotas (exceto `/health`) requerem JWT token.

```bash
# 1. Registrar usuário
curl -X POST http://localhost:3002/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "cpf": "12345678901",
    "password": "SenhaForte123",
    "email": "dev@example.com",
    "firstName": "Dev",
    "lastName": "User"
  }'

# 2. Login (obter token)
curl -X POST http://localhost:3002/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "cpf": "12345678901",
    "password": "SenhaForte123"
  }'

# 3. Usar token nas requisições
curl -X GET http://localhost:3001/api/v1/customers \
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

## 📖 Comandos Principais

### Gerenciamento Geral

```bash
make help           # Lista todos os comandos disponíveis
make status-all     # Status de todos os containers
make health-all     # Health check de todos os serviços
make urls           # Exibe URLs dos serviços
make up-all         # Inicia todos os serviços
make down-all       # Para todos os serviços
make reset          # Reset completo (remove volumes e dados)
```

### Auth Service

```bash
make up-auth        # Iniciar
make down-auth      # Parar
make logs-auth      # Logs em tempo real
make test-auth      # Executar testes
make shell-auth     # Acessar shell do container
```

### Main API

```bash
make up-api         # Iniciar
make down-api       # Parar
make logs-api       # Logs em tempo real
make migrate-api    # Executar migrations (Prisma)
make seed-api       # Popular banco com dados
make studio-api     # Abrir Prisma Studio
make test-api       # Executar testes
make shell-api      # Acessar shell do container
```

### Sale API (Sales)

```bash
make up-api-sale       # Iniciar
make down-api-sale     # Parar
make logs-api-sale     # Logs em tempo real
make migrate-api-sale  # Executar migrations (Prisma)
make studio-api-sale   # Abrir Prisma Studio
make test-api-sale     # Executar testes
make shell-api-sale    # Acessar shell do container
```

### Database

```bash
make shell-db           # PostgreSQL da Main API
make shell-keycloak-db  # PostgreSQL do Keycloak
```

## 🔄 Workflow Diário

```bash
# Iniciar ambiente
make up-all

# Verificar saúde
make health-all

# Desenvolver... (hot reload ativo)

# Ver logs (em terminais separados)
make logs-api
make logs-api-sale

# Rodar testes
make test-api

# Parar ambiente
make down-all
```

## 🗄️ Diferenças de Schema

| Tabela | Main API | Sale API | Descrição |
|--------|----------|----------|-----------|
| `Customer` | ✅ | ✅ | Dados espelhados |
| `Vehicle` | ✅ | ✅ | Dados espelhados |
| `Sale` | ❌ | ✅ | **Apenas Sale API** |
| `SaleStatus` enum | ❌ | ✅ | PENDING, PAID, CANCELLED |

## 🐛 Troubleshooting

### Container da API em loop de restart

**Sintoma:** Container reiniciando constantemente

```bash
# Ver logs
make logs-api

# Se erro no seed.ts (referências a Sale), já foi corrigido
# Reinicie o container
cd fiap-pos-tech-api
docker compose restart fiap-pos-tech-api-dev
```

### Token JWT não valida (INVALID_TOKEN)

**Sintoma:** APIs retornam 401 mesmo com token válido

**Causa:** APIs não conseguem acessar Keycloak para validar JWT

**Solução:**

```bash
# 1. Verificar se Keycloak está acessível
curl http://localhost:8080/health/ready

# 2. Testar conectividade interna
docker exec fiap-pos-tech-api-dev \
  curl -s http://fiap-keycloak:8080/health/ready

# 3. Se falhar, reiniciar na ordem correta
make down-all
make up-auth
sleep 90  # IMPORTANTE: Aguardar Keycloak
make up-api
make up-api-sale
```

### Migrations falhando

```bash
# Verificar se banco está rodando
cd fiap-pos-tech-api
docker compose ps

# Reiniciar serviços
docker compose restart fiap-pos-tech-api-db
sleep 5
docker compose restart fiap-pos-tech-api-dev

# Tentar migration novamente
make migrate-api
```

### Reset Completo

```bash
# Para tudo e remove volumes/dados
make reset

# Reinicializar
make setup-all
./setup-network.sh
make migrate-api
make seed-api
make migrate-api-sale
```

## 📋 Pré-requisitos

- Docker 20.10+
- Docker Compose v2
- Git
- Make
- curl

## 🌐 Variáveis de Ambiente

Cada serviço possui `.env` próprio. Criados automaticamente por `make setup`.

**Principais variáveis:**

```env
# fiap-pos-tech-api/.env
KEYCLOAK_URL=http://fiap-keycloak:8080
WEBHOOK_SECRET=your_webhook_secret

# fiap-pos-tech-api-sale/.env
KEYCLOAK_URL=http://fiap-keycloak:8080
MAIN_API_URL=http://fiap-pos-tech-api-dev:3001/api/v1
```

## 🔧 Comandos Avançados

### Rebuild sem cache

```bash
make rebuild-auth
make rebuild-api
make rebuild-api-sale
```

### Atualizar código

```bash
make pull    # Git pull em todos os repos
make update  # Pull + rebuild
```

### Acessar banco de dados

```bash
# Main API
make shell-db
# Dentro: \dt (listar tabelas), SELECT * FROM customers;

# Sale API
cd fiap-pos-tech-api-sale
docker compose exec fiap-pos-tech-api-sale-db \
  psql -U fiap_sale_user -d fiap_sale_api_db
```

## 📄 Documentação Adicional

- [fiap-pos-tech-auth](https://github.com/jhonataneduardo/fiap-pos-tech-auth) - Detalhes do Auth Service
- [fiap-pos-tech-api](https://github.com/jhonataneduardo/fiap-pos-tech-api) - Detalhes da Main API
- [fiap-pos-tech-api-sale](https://github.com/jhonataneduardo/fiap-pos-tech-api-sale) - Detalhes da Sale API

## 🎯 Resumo Executivo

```bash
# Setup completo (primeira vez)
make setup && make setup-all && ./setup-network.sh
make migrate-api && make seed-api && make migrate-api-sale

# Verificar
make health-all && make urls

# Dia a dia
make up-all          # Iniciar
make down-all        # Parar

# Problemas?
make reset           # Reset completo
```

---

**FIAP Pós-Tech - Arquitetura de Software** 🎓
