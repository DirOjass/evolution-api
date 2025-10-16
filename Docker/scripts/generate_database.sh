#!/bin/bash

source ./Docker/scripts/env_functions.sh

if [ "$SOCKER_ENV" == "true" ]; then
  export_env_vars
fi

# ---------------------------------------------------
# DEBUG - Mostrar valor da variável no build
# ---------------------------------------------------
echo "[DEBUG] DATABASE_PROVIDER (raw) = '$DATABASE_PROVIDER'"

# Normaliza pra minúsculo e remove espaços
PROVIDER="$(printf '%s' "$DATABASE_PROVIDER" | tr '[:upper:]' '[:lower:]' | xargs)"

# ---------------------------------------------------
# Seleciona schema conforme o provider
# ---------------------------------------------------
case "$PROVIDER" in
  postgres|postgresql|pg)
    SCHEMA="./prisma/postgresql-schema.prisma"
    ;;
  psql_bouncer|psql-bouncer|bouncer)
    SCHEMA="./prisma/psql_bouncer-schema.prisma"
    ;;
  mysql|maria|mariadb)
    SCHEMA="./prisma/mysql-schema.prisma"
    ;;
  *)
    echo "[ERROR] DATABASE_PROVIDER='$DATABASE_PROVIDER' inválido."
    echo "        Use: postgres | postgresql | mysql | psql_bouncer"
    exit 1
    ;;
esac

echo "[DEBUG] Provider normalizado = '$PROVIDER'"
echo "[DEBUG] Schema selecionado = '$SCHEMA'"

# ---------------------------------------------------
# Geração do Prisma Client
# ---------------------------------------------------
npx prisma generate --schema "$SCHEMA"
EXIT=$?

if [ $EXIT -ne 0 ]; then
  echo "[ERROR] Prisma generate falhou (exit $EXIT)"
  exit $EXIT
else
  echo "[INFO] Prisma generate concluído com sucesso usando '$SCHEMA'"
fi
