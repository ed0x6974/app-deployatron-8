#!/bin/bash
set -euo pipefail

: "${PG_HOST:?Environment variable PG_HOST is required}"
: "${PG_PORT:?Environment variable PG_PORT is required}"
: "${PG_SUPER_USER_NAME:?Environment variable PG_SUPER_USER_NAME is required}"
: "${PG_SUPER_USER_PASS:?Environment variable PG_SUPER_USER_PASS is required}"
: "${PG_PROD_USER_NAME:?Enviroment variable PG_PROD_USER_NAME is required}"
: "${PG_PROD_DB_NAME:?Enviroment variable PG_PROD_DB_NAME is required}"
: "${PG_PROD_USER_PASS:?Enviroment variable PG_PROD_USER_PASS is required}"
: "${STAGING_NAME:?Environment variable STAGING_NAME is required}"
: "${PG_STAGING_USER_PASS:?Environment variable PG_STAGING_USER_PASS is required}"
: "${APP_PATH:?Environment variable APP_PATH is required}"

# remove user
DB_EXISTS=$(PGPASSWORD="$PG_SUPER_USER_PASS" psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_SUPER_USER_NAME" -tAc "SELECT 1 FROM pg_database WHERE datname='$STAGING_NAME';")
if [[ "$DB_EXISTS" == "1" ]]; then
    PGPASSWORD="$PG_SUPER_USER_PASS" psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_SUPER_USER_NAME" -c "DROP DATABASE \"$STAGING_NAME\";"
    echo "Database $STAGING_NAME was dropped."
else
    echo "Database $STAGING_NAME does not exist, skipping drop."
fi

# remove db
USER_EXISTS=$(PGPASSWORD="$PG_SUPER_USER_PASS" psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_SUPER_USER_NAME" -tAc "SELECT 1 FROM pg_roles WHERE rolname='$STAGING_NAME';")
if [[ "$USER_EXISTS" == "1" ]]; then
    PGPASSWORD="$PG_SUPER_USER_PASS" psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_SUPER_USER_NAME" -c "DROP USER \"$STAGING_NAME\";"
    echo "User $STAGING_NAME was dropped."
else
    echo "User $STAGING_NAME does not exist, skipping drop."
fi

echo "🎉 Done!"
