#!/bin/sh
set -e

# Ensure these exist (Railway sets them, this just makes it explicit)
: "${KRATOS_PUBLIC_URL:?missing}"
: "${ALLOWED_RETURN_URL:?missing}"
: "${CORS_ALLOWED_ORIGIN:?missing}"
: "${COOKIE_DOMAIN:?missing}"
: "${DSN:?missing}"
: "${SECRETS_DEFAULT:?missing}"
: "${SECRETS_COOKIE:?missing}"
: "${COURIER_SMTP_CONNECTION_URI:?missing}"
: "${COURIER_SMTP_FROM_ADDRESS:?missing}"
: "${COURIER_SMTP_FROM_NAME:?missing}"

# Generate Kratos config
envsubst < /etc/kratos/kratos.yml > /tmp/kratos.yml

# Run migrations
kratos -c /tmp/kratos.yml migrate sql -e --yes

# Start Kratos
exec kratos -c /tmp/kratos.yml serve --watch-courier