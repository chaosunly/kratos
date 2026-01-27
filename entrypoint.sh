#!/bin/sh
set -e

# Set default values for environment variables
export KRATOS_PUBLIC_URL="${KRATOS_PUBLIC_URL:-http://localhost:4433}"
export KRATOS_ADMIN_URL="${KRATOS_ADMIN_URL:-http://localhost:4434}"
export DEFAULT_RETURN_URL="${DEFAULT_RETURN_URL:-http://localhost:3000}"
export ALLOWED_RETURN_URL="${ALLOWED_RETURN_URL:-http://localhost:3000}"
export KRATOS_UI_URL="${KRATOS_UI_URL:-http://localhost:3000}"

# Railway injects PORT dynamically
export SERVE_PUBLIC_PORT="${PORT:-4433}"

# Substitute environment variables in the config file
envsubst < /etc/kratos/kratos.yml > /tmp/kratos.yml

# Run DB migrations
kratos -c /tmp/kratos.yml migrate sql -e --yes

# Start Kratos
kratos -c /tmp/kratos.yml serve