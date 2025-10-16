#!/bin/bash

# ================================
# Deploy Database Script Corrigido
# ================================
# Função: Executar migrations e gerar Prisma Client conforme o provider
# Compatível com: postgresql | mysql | psql_bouncer
# Corrige erro de caminho do schema (../app/prisma → ./prisma)
# ================================

# Carrega variáveis do ambiente
source ./Docker/scripts/env_functions.sh

# Garante que as variáveis do .env sejam exportadas localmente
if [ "$DOCKER_ENV" != "true" ]; then
    export_env_vars
fi

# Verifica se o provider é válido
if [[ "$DATABASE_PROVIDER" == "postgresql" || "$DATABASE_PROVIDER" == "mysql" || "$DATABASE_PROVIDER" == "psql_bouncer" ]]; then
    export DATABASE_URL
    echo "Deploying migrations for $DATABASE_PROVIDER"
    echo "Database URL: $DATABASE_URL"

    # Define qual schema deve ser usado com base no provider
    if [[ "$DATABASE_PROVIDER" == "postgresql" ]]; then
        SCHEMA_PATH="./prisma/postgresql-schema.prisma"
    elif [[ "$DATABASE_PROVIDER" == "mysql" ]]; then
        SCHEMA_PATH="./prisma/mysql-schema.prisma"
    elif [[ "$DATABASE_PROVIDER" == "psql_bouncer" ]]; then
        SCHEMA_PATH="./prisma/psql_bouncer-schema.prisma"
    fi

    # Verifica se o arquivo existe antes de continuar
    if [ ! -f "$SCHEMA_PATH" ]; then
        echo "❌ ERRO: Schema file não encontrado em $SCHEMA_PATH"
        exit 1
    fi

    echo "🔄 Usando schema: $SCHEMA_PATH"

    # Executa as migrations com o schema correto
    npx prisma migrate deploy --schema="$SCHEMA_PATH"
    if [ $? -ne 0 ]; then
        echo "❌ Migration failed"
        exit 1
    else
        echo "✅ Migration succeeded"
    fi

    # Gera o Prisma Client com o mesmo schema
    npx prisma generate --schema="$SCHEMA_PATH"
    if [ $? -ne 0 ]; then
        echo "❌ Prisma generate failed"
        exit 1
    else
        echo "✅ Prisma generate succeeded"
    fi

else
    echo "❌ Error: Database provider '$DATABASE_PROVIDER' inválido."
    echo "Use um dos seguintes: postgresql | mysql | psql_bouncer"
    exit 1
fi
