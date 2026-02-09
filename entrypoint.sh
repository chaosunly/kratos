#!/bin/sh
set -e

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

# Generate Kratos config
envsubst < /etc/kratos/kratos.yml > /tmp/kratos.yml

# Run migrations
kratos -c /tmp/kratos.yml migrate sql -e --yes

# Start Kratos (no public exposure - accessed via gateway only)
exec kratos -c /tmp/kratos.yml serve --watch-courier
