#!/bin/sh
set -e

# Ensure required environment variables exist
: "${ORY_KRATOS_PUBLIC_URL:?ORY_KRATOS_PUBLIC_URL is required (e.g., https://gateway.railway.app/.ory)}"
: "${KRATOS_UI_URL:?KRATOS_UI_URL is required (e.g., https://gateway.railway.app)}"
: "${DEFAULT_RETURN_URL:?DEFAULT_RETURN_URL is required (e.g., https://gateway.railway.app/dashboard)}"
: "${ALLOWED_RETURN_URL:?ALLOWED_RETURN_URL is required (e.g., https://gateway.railway.app)}"
: "${CORS_ALLOWED_ORIGIN:?CORS_ALLOWED_ORIGIN is required}"
: "${COOKIE_DOMAIN:?COOKIE_DOMAIN is required}"
: "${DSN:?DSN is required}"
: "${SECRETS_DEFAULT:?SECRETS_DEFAULT is required}"
: "${SECRETS_COOKIE:?SECRETS_COOKIE is required}"
: "${SECRETS_CIPHER:?SECRETS_CIPHER is required (generate with: openssl rand -base64 32)}"
: "${COURIER_SMTP_CONNECTION_URI:?COURIER_SMTP_CONNECTION_URI is required}"
: "${COURIER_SMTP_FROM_ADDRESS:?COURIER_SMTP_FROM_ADDRESS is required}"
: "${COURIER_SMTP_FROM_NAME:?COURIER_SMTP_FROM_NAME is required}"

echo "Configuration validation:"
echo "  ORY_KRATOS_PUBLIC_URL: ${ORY_KRATOS_PUBLIC_URL}"
echo "  KRATOS_UI_URL: ${KRATOS_UI_URL}"
echo "  DEFAULT_RETURN_URL: ${DEFAULT_RETURN_URL}"
echo "  COOKIE_DOMAIN: ${COOKIE_DOMAIN}"

# Generate Kratos config
envsubst < /etc/kratos/kratos.yml > /tmp/kratos.yml

# Run migrations
kratos -c /tmp/kratos.yml migrate sql -e --yes

# Start Kratos
exec kratos -c /tmp/kratos.yml serve --watch-courier