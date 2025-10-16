#!/bin/bash

source ./Docker/scripts/env_functions.sh

if [ "$DOCKER_ENV" == "true" ]; then
  export_env_vars
fi

if [[ "$DATABASE_PROVIDER" == "postgresql" || "$DATABASE_PROVIDER" == "mysql" || "$DATABASE_PROVIDER" == "psql_bouncer" ]]; then
  export DATABASE_URL
  echo "Generating database for $DATABASE_PROVIDER"
  echo "Database URL: $DATABASE_URL"

  if [[ "$DATABASE_PROVIDER" == "psql_bouncer" ]]; then
    npx prisma generate --schema=./prisma/psql_bouncer-schema.prisma
  elif [[ "$DATABASE_PROVIDER" == "postgresql" ]]; then
    npx prisma generate --schema=./prisma/postgresql-schema.prisma
  elif [[ "$DATABASE_PROVIDER" == "mysql" ]]; then
    npx prisma generate --schema=./prisma/mysql-schema.prisma
  fi

  if [ $? -ne 0 ]; then
    echo "Prisma generate failed"
    exit 1
  else
    echo "Prisma generate succeeded"
  fi
else
  echo "Error: Database provider $DATABASE_PROVIDER invalid."
  exit 1
fi
