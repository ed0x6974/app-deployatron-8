#!/usr/bin/env bash

: "${PG_HOST:?Environment variable PG_HOST is required}"
: "${PG_PORT:?Environment variable PG_PORT is required}"
: "${STAGING_NAME:?Environment variable STAGING_NAME is required}"
: "${PG_STAGING_USER_PASS:?Environment variable PG_STAGING_USER_PASS is required}"
: "${APP_PATH:?Environment variable APP_PATH is required}"

STAGING_PATH="$APP_PATH/staging/$STAGING_NAME"
CONFIG_PATH="$STAGING_PATH/ecosystem.config.js"

mkdir -p "$STAGING_PATH/logs"

cat > "$CONFIG_PATH" << EOF
module.exports = {
  apps: [
    {
      name: "$STAGING_NAME",
      script: "$STAGING_PATH/api/server.js",
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: "500M",
      env: {
        DB_USER: "$STAGING_NAME",
        DB_HOST: "$PG_HOST",
        DB_NAME: "$STAGING_NAME",
        DB_PASSWORD: "$PG_STAGING_USER_PASS",
        DB_PORT: $PG_PORT,
        MODE: "staging",
      },
      log_file: "$STAGING_PATH/logs/combined.log",
      out_file: "$STAGING_PATH/logs/out.log",
      error_file: "$STAGING_PATH/logs/error.log",
      time: true
    },
  ],
};
EOF

if pm2 list | grep -q "$STAGING_NAME"; then
  echo "Process $STAGING_NAME already running. Restarting..."
  pm2 restart "$STAGING_NAME"
else
  echo "Process $STAGING_NAME not running. Starting..."
  pm2 start "$CONFIG_PATH"
fi

pm2 save