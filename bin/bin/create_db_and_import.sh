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

echo "Using environment variables:"
echo "----------------------------------------"
echo "  PG_HOST               = $PG_HOST"
echo "  PG_PORT               = $PG_PORT"
echo "  PG_SUPER_USER_NAME    = $PG_SUPER_USER_NAME"
echo "  PG_PROD_USER_NAME     = $PG_PROD_USER_NAME"
echo "  PG_PROD_DB_NAME       = $PG_PROD_DB_NAME"
echo "  STAGING_DB_NAME       = $STAGING_NAME"
echo "  STAGING_DB_USER       = $STAGING_NAME"
echo ""

check_password() {
    local var_name="$1"
    local var_value="$2"
    if [ -z "$var_value" ]; then
        echo "  $var_name                = NOT SET!"
    else
        echo "  $var_name                = ******"
    fi
}

echo "Passwords:"
echo "----------------------------------------"
check_password "PG_SUPER_USER_PASS" "$PG_SUPER_USER_PASS"
check_password "PG_PROD_USER_PASS" "$PG_PROD_USER_PASS"
check_password "PG_STAGING_USER_PASS" "$PG_STAGING_USER_PASS"
echo "================="

# create user
USER_EXISTS=$(PGPASSWORD="$PG_SUPER_USER_PASS" psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_SUPER_USER_NAME" -tAc "SELECT 1 FROM pg_roles WHERE rolname='$STAGING_NAME';")
if [[ "$USER_EXISTS" == "1" ]]; then
    echo "User $STAGING_NAME exists."
else
    PGPASSWORD="$PG_SUPER_USER_PASS" psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_SUPER_USER_NAME" -c "CREATE USER \"$STAGING_NAME\" WITH PASSWORD '$PG_STAGING_USER_PASS';"
    echo "User $STAGING_NAME was created."
fi

# create db
DB_EXISTS=$(PGPASSWORD="$PG_SUPER_USER_PASS" psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_SUPER_USER_NAME" -tAc "SELECT 1 FROM pg_database WHERE datname='$STAGING_NAME';")
if [[ "$DB_EXISTS" == "1" ]]; then
    echo "Database $STAGING_NAME exists."
else
    PGPASSWORD="$PG_SUPER_USER_PASS" psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_SUPER_USER_NAME" -c "CREATE DATABASE \"$STAGING_NAME\" OWNER \"$STAGING_NAME\";"
    echo "Database $STAGING_NAME was created."
fi

# set db permissions for user
PGPASSWORD="$PG_SUPER_USER_PASS" psql -h $PG_HOST -p $PG_PORT -U $PG_SUPER_USER_NAME -c "GRANT ALL PRIVILEGES ON DATABASE \"$STAGING_NAME\" TO \"$STAGING_NAME\";"
echo "User $STAGING_NAME granted all privileges on database $STAGING_NAME."

# create dump from production db
DUMP_DIR="$APP_PATH/staging/$STAGING_NAME/db-dump"
DUMP_FILE="$DUMP_DIR/${PG_PROD_DB_NAME}_$(date +%F_%H-%M-%S).sql"

mkdir -p "$DUMP_DIR"

echo "Generating dump from production database: $PG_PROD_DB_NAME"
PGPASSWORD="$PG_PROD_USER_PASS" pg_dump \
  -h "$PG_HOST" \
  -p "$PG_PORT" \
  -U "$PG_PROD_USER_NAME" \
  -F p \
  "$PG_PROD_DB_NAME" \
  > "$DUMP_FILE"

echo "Production dump stored at: $DUMP_FILE"

echo "🎉 Done!"
