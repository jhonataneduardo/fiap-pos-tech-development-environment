# FIAP Pós-Tech - Ambiente de Desenvolvimento

Este repositório contém a orquestração completa dos serviços FIAP Pós-Tech usando Docker Compose e automação via Makefile.

## 🚀 Quick Start

```bash
# 1. Setup completo (clone + build + configuração)
make setup

# 2. Revise o arquivo .env (criado automaticamente)

# 3. Inicie os serviços
make up

# 4. Configure o banco de dados
make migrate-api
make seed-api

# 5. Acesse os serviços
make urls
```

## 📋 Serviços

O ambiente gerencia os seguintes serviços:

- **fiap-pos-tech-db**: Banco de dados PostgreSQL 15 para a API (porta 5432)
- **keycloak-db**: Banco de dados PostgreSQL 15 para o Keycloak (porta 5433)
- **keycloak**: Servidor de autenticação Keycloak (porta 8080)
- **fiap-pos-tech-api**: API principal do sistema (porta 3001)
- **fiap-pos-tech-auth**: Serviço de autenticação (porta 3002)

## 🛠️ Pré-requisitos

- Docker
- Docker Compose
- Git
- Make

## 🎯 Configuração

### Opção 1: Setup Automático com Makefile (Recomendado)

```bash
# Clone os repositórios e configure o ambiente
make setup
```

Este comando irá:
1. ✅ Clonar `fiap-pos-tech-api` e `fiap-pos-tech-auth` (se ainda não existirem)
2. ✅ Criar arquivo `.env` a partir do `.env.example`
3. ✅ Fazer build de todos os serviços
4. ✅ Exibir próximos passos

### Opção 2: Setup Manual

```bash
# 1. Clone os repositórios
git clone https://github.com/jhonataneduardo/fiap-pos-tech-api.git
git clone https://github.com/jhonataneduardo/fiap-pos-tech-auth.git

# 2. Configure as variáveis de ambiente
cp .env.example .env

# 3. Ajuste o .env conforme necessário
```

### Estrutura esperada:
```
pos-tech/
├── Makefile
├── docker-compose.yml
├── .env
├── .env.example
├── fiap-pos-tech-api/
└── fiap-pos-tech-auth/
```

### Variáveis de Ambiente

Principais variáveis do arquivo `.env`:

- **Database API**: `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`
- **Database Keycloak**: `KEYCLOAK_DB_NAME`, `KEYCLOAK_DB_USER`, `KEYCLOAK_DB_PASSWORD`
- **Keycloak**: `KEYCLOAK_ADMIN_USERNAME`, `KEYCLOAK_ADMIN_PASSWORD`
- **Portas**: `API_PORT`, `AUTH_PORT`, `KEYCLOAK_PORT`

## 📖 Comandos do Makefile

### 💡 Ajuda

```bash
make help          # Exibe todos os comandos disponíveis
```

### 🛠️ Setup

```bash
make clone         # Clona os repositórios API e Auth
make check-env     # Verifica/cria arquivo .env
make setup         # Setup completo (clone + env + build)
```

### 🐳 Docker Operations

```bash
make up            # Inicia todos os serviços
make down          # Para todos os serviços
make build         # Build de todos os serviços
make rebuild       # Rebuild completo (sem cache)
make restart       # Reinicia todos os serviços
```

### 📊 Monitoramento

```bash
make logs          # Logs de todos os containers
make logs-api      # Logs apenas da API
make logs-auth     # Logs apenas do Auth
make logs-db       # Logs do PostgreSQL
make logs-keycloak # Logs do Keycloak
make status        # Status de todos os containers
make health        # Verifica saúde dos serviços
```

### 🗄️ Operações de Banco de Dados

```bash
make migrate-api         # Executa migrations do Prisma
make migrate-deploy-api  # Deploy de migrations (produção)
make seed-api            # Popula banco com dados de exemplo
make studio-api          # Abre Prisma Studio
```

### 💻 Acesso Shell

```bash
make shell-api         # Acessa shell do container API
make shell-auth        # Acessa shell do container Auth
make shell-db          # Acessa PostgreSQL CLI (API)
make shell-keycloak-db # Acessa PostgreSQL CLI (Keycloak)
```

### 🧪 Testes

```bash
make test-api          # Executa testes da API
make test-api-watch    # Testes em modo watch
make test-api-coverage # Testes com cobertura
```

### 🧹 Limpeza

```bash
make clean         # Remove containers, volumes e imagens
make clean-volumes # Remove apenas volumes
make reset         # Reset completo do ambiente
```

### 🔄 Desenvolvimento

```bash
make pull          # Atualiza código dos repositórios
make update        # Pull + rebuild + restart
make install-deps  # Instala dependências
make urls          # Exibe URLs de todos os serviços
```

## 🚦 Uso Básico

### Iniciando o Ambiente

**Com Makefile:**
```bash
make up
```

**Com Docker Compose:**
```bash
docker-compose up -d
```

Este comando irá:
1. Criar as redes necessárias
2. Iniciar os bancos de dados (API e Keycloak)
3. Aguardar health checks dos bancos
4. Iniciar o Keycloak
5. Aguardar health check do Keycloak
6. Iniciar a API (com migrations e seed automáticos)
7. Iniciar o serviço de autenticação

### Verificando Status

**Com Makefile:**
```bash
make status        # Status detalhado
make health        # Health check dos serviços
```

**Com Docker Compose:**
```bash
docker-compose ps
```

### Visualizando Logs

**Com Makefile:**
```bash
make logs          # Todos os serviços
make logs-api      # Apenas API
```

**Com Docker Compose:**
```bash
# Todos os serviços
docker-compose logs -f

# Serviço específico
docker-compose logs -f fiap-pos-tech-api
docker-compose logs -f fiap-pos-tech-auth
docker-compose logs -f keycloak
```

### Parando os Serviços

**Com Makefile:**
```bash
make down
```

**Com Docker Compose:**
```bash
docker-compose down
```

### Parando e Removendo Volumes

**Com Makefile:**
```bash
make clean-volumes  # Com confirmação
```

**Com Docker Compose:**
```bash
docker-compose down -v
```

### Rebuild dos Serviços

**Com Makefile:**
```bash
make rebuild       # Rebuild completo
make update        # Pull + rebuild + restart
```

**Com Docker Compose:**
```bash
# Rebuild de todos os serviços
docker-compose up -d --build

# Rebuild de um serviço específico
docker-compose up -d --build fiap-pos-tech-api
```

## 🌐 Acessando os Serviços

**Visualize todas as URLs:**
```bash
make urls
```

Após iniciar os serviços:

- **API**: http://localhost:3001
  - Swagger: http://localhost:3001/api-docs
- **Auth Service**: http://localhost:3002
  - Swagger: http://localhost:3002/api-docs
- **Keycloak Admin Console**: http://localhost:8080
  - Usuário: `admin` (configurável via `.env`)
  - Senha: `admin` (configurável via `.env`)

## 💻 Desenvolvimento

Os serviços estão configurados em modo de desenvolvimento com:
- **Hot reload**: Mudanças no código são refletidas automaticamente
- **Volumes montados**: Código fonte é montado nos containers
- **Migrations automáticas**: A API executa migrations do Prisma automaticamente
- **Seed automático**: A API executa o seed do banco automaticamente

### Estrutura de volumes

```yaml
API:
  - ./fiap-pos-tech-api/src:/app/src
  - ./fiap-pos-tech-api/prisma:/app/prisma

Auth:
  - ./fiap-pos-tech-auth/src:/app/src
```

### Trabalhando com o Banco de Dados

```bash
# Executar migrations
make migrate-api

# Popular com dados de exemplo
make seed-api

# Abrir Prisma Studio (interface visual)
make studio-api

# Acessar banco via CLI
make shell-db
```

### Executando Testes

```bash
# Rodar todos os testes
make test-api

# Modo watch (re-executa ao salvar)
make test-api-watch

# Com cobertura de código
make test-api-coverage
```

## 🐛 Troubleshooting

### Serviços não iniciam

1. Verifique se as portas não estão em uso:
```bash
lsof -i :3001  # API
lsof -i :3002  # Auth
lsof -i :8080  # Keycloak
lsof -i :5432  # PostgreSQL API
lsof -i :5433  # PostgreSQL Keycloak
```

2. Verifique os logs:
```bash
make logs
```

### Keycloak não está pronto

O Keycloak pode demorar até 2 minutos para iniciar completamente. Aguarde o health check:

```bash
make logs-keycloak
# ou
make health
```

### API com erro de conexão ao banco

Verifique se o banco de dados está saudável:

```bash
make status
```

Se necessário, recrie o ambiente:

```bash
make down
make up
```

### Resetar completamente o ambiente

**Com Makefile (recomendado):**
```bash
make reset  # Com confirmação interativa
```

**Com Docker Compose:**
```bash
# Para tudo e remove volumes
docker-compose down -v

# Remove imagens
docker-compose down --rmi all

# Reinicia do zero
docker-compose up -d --build
```

### Problemas após atualizar código

```bash
# Atualiza dependências
make install-deps

# Ou rebuilda completamente
make rebuild
make restart
```

## 🌐 Rede

Todos os serviços estão na mesma rede (`fiap-pos-tech-network`), permitindo comunicação interna:

- API acessa Keycloak via: `http://keycloak:8080`
- API acessa banco via: `postgresql://fiap-pos-tech-db:5432`
- Auth acessa Keycloak via: `http://keycloak:8080`

## 💾 Volumes

Dados persistentes são armazenados em volumes Docker:
- `postgres_api_data`: Dados do PostgreSQL da API
- `keycloak_postgres_data`: Dados do PostgreSQL do Keycloak

## 🔧 Comandos Úteis

### Acessar containers

```bash
make shell-api      # Shell da API
make shell-auth     # Shell do Auth
make shell-db       # PostgreSQL CLI
```

### Informações do ambiente

```bash
make status         # Status dos containers
make health         # Health check
make urls           # URLs dos serviços
docker-compose stats # Uso de recursos
```

### Gerenciar serviços individuais

```bash
docker-compose restart fiap-pos-tech-api
docker-compose stop fiap-pos-tech-api
docker-compose start fiap-pos-tech-api
```

## 📝 Fluxo de Trabalho Recomendado

### Primeiro uso

```bash
# 1. Setup inicial
make setup

# 2. Revisar .env
nano .env  # ou seu editor preferido

# 3. Subir serviços
make up

# 4. Configurar banco
make migrate-api
make seed-api

# 5. Verificar
make health
make urls
```

### Dia a dia

```bash
# Iniciar trabalho
make up

# Desenvolver...
# (hot reload ativo)

# Rodar testes
make test-api-watch

# Visualizar logs
make logs-api

# Finalizar
make down
```

### Após pull de código

```bash
# Atualizar tudo
make update

# Ou manualmente
make pull
make rebuild
make restart
```

## 🤝 Contribuindo

Para contribuir com o projeto:

1. Faça suas alterações no código
2. Os serviços recarregarão automaticamente
3. Teste suas mudanças: `make test-api`
4. Verifique os logs: `make logs-api`
5. Faça commit e push

## 📄 Licença

MIT

## 🆘 Suporte

### Comandos de diagnóstico

```bash
make status        # Status dos containers
make health        # Health check dos serviços
make logs          # Logs completos
```

### Links úteis

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [Prisma Documentation](https://www.prisma.io/docs/)

### Problemas comuns

| Problema | Solução |
|----------|---------|
| Porta em uso | `lsof -i :<porta>` e mate o processo |
| Container não inicia | `make logs-<serviço>` para ver o erro |
| Banco não conecta | `make status` e verifique health |
| Código não atualiza | `make rebuild` |
| Erro em migrations | `make shell-api` e debug manualmente |

---

Feito com ❤️ para FIAP Pós-Tech
