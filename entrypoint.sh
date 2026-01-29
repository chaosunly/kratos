#!/bin/sh
set -e

export SERVE_PUBLIC_PORT="${PORT:-8080}"

# Ensure these exist (Railway sets them, this just makes it explicit)
: "${KRATOS_PUBLIC_URL:?missing}"
: "${KRATOS_UI_URL:?missing}"
: "${DEFAULT_RETURN_URL:?missing}"
: "${ALLOWED_RETURN_URL:?missing}"
: "${CORS_ALLOWED_ORIGIN:?missing}"
: "${DSN:?missing}"
: "${SECRETS_DEFAULT:?missing}"
: "${SECRETS_COOKIE:?missing}"
: "${COURIER_SMTP_CONNECTION_URI:?missing}"

envsubst < /etc/kratos/kratos.yml > /tmp/kratos.yml
kratos -c /tmp/kratos.yml migrate sql -e --yes
kratos -c /tmp/kratos.yml serve --watch-courier
