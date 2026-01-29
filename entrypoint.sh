#!/bin/sh
set -e

export SERVE_PUBLIC_PORT="${PORT:-8080}"

# Substitute environment variables in the config file
envsubst < /etc/kratos/kratos.yml > /tmp/kratos.yml

# Run DB migrations
kratos -c /tmp/kratos.yml migrate sql -e --yes

# Start Kratos
kratos -c /etc/kratos/kratos.yml serve --watch-courier
