#!/bin/bash

# Script para configurar e iniciar todos os serviços FIAP Pos Tech
# com rede compartilhada

set -e

echo "🚀 FIAP Pos Tech - Setup de Rede Compartilhada"
echo "================================================"
echo ""

# Criar rede externa se não existir
echo "📡 Verificando rede compartilhada..."
if docker network inspect fiap-pos-tech-network >/dev/null 2>&1; then
    echo "✅ Rede 'fiap-pos-tech-network' já existe"
else
    echo "🔧 Criando rede 'fiap-pos-tech-network'..."
    docker network create fiap-pos-tech-network
    echo "✅ Rede criada com sucesso"
fi

echo ""
echo "================================================"
echo "📋 Ordem de Inicialização dos Serviços"
echo "================================================"
echo ""
echo "1. fiap-pos-tech-auth (Keycloak + Auth Service)"
echo "2. fiap-pos-tech-api (Main API)"
echo "3. fiap-pos-tech-api-read (Read API)"
echo ""

# Verificar se deve iniciar automaticamente
read -p "Deseja iniciar todos os serviços agora? (s/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo ""
    echo "🔐 Iniciando Auth Service (Keycloak)..."
    echo "================================================"
    cd fiap-pos-tech-auth
    docker compose --profile dev up -d
    cd ..
    
    echo ""
    echo "⏳ Aguardando Keycloak ficar pronto (60 segundos)..."
    sleep 60
    
    echo ""
    echo "🗄️  Iniciando Main API..."
    echo "================================================"
    cd fiap-pos-tech-api
    docker compose --profile dev up -d
    cd ..
    
    echo ""
    echo "📖 Iniciando Read API..."
    echo "================================================"
    cd fiap-pos-tech-api-read
    docker compose --profile dev up -d
    cd ..
    
    echo ""
    echo "✅ Todos os serviços iniciados!"
    echo ""
    echo "🌐 URLs de Acesso:"
    echo "  - Keycloak Admin:  http://localhost:8080 (admin/admin)"
    echo "  - Auth Service:    http://localhost:3002"
    echo "  - Main API:        http://localhost:3001"
    echo "  - Read API:        http://localhost:3003"
    echo ""
    echo "📚 Swagger Docs:"
    echo "  - Auth Service:    http://localhost:3002/api-docs"
    echo "  - Main API:        http://localhost:3001/api-docs"
    echo "  - Read API:        http://localhost:3003/api-docs"
    echo ""
else
    echo ""
    echo "ℹ️  Rede criada. Para iniciar os serviços manualmente:"
    echo ""
    echo "1. cd fiap-pos-tech-auth && docker compose --profile dev up -d"
    echo "2. Aguarde ~60s para Keycloak ficar pronto"
    echo "3. cd ../fiap-pos-tech-api && docker compose --profile dev up -d"
    echo "4. cd ../fiap-pos-tech-api-read && docker compose --profile dev up -d"
    echo ""
fi

echo "================================================"
echo "📊 Para verificar a rede:"
echo "   docker network inspect fiap-pos-tech-network"
echo ""
echo "🛑 Para parar todos os serviços:"
echo "   cd fiap-pos-tech-auth && docker compose --profile dev down"
echo "   cd ../fiap-pos-tech-api && docker compose --profile dev down"
echo "   cd ../fiap-pos-tech-api-read && docker compose --profile dev down"
echo "================================================"
