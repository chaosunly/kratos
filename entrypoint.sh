#!/bin/sh
set -e

# Substitute environment variables in the config file
envsubst < /etc/kratos/kratos.yml > /tmp/kratos.yml

# Run DB migrations
kratos -c /tmp/kratos.yml migrate sql -e --yes

# Start Kratos
kratos -c /tmp/kratos.yml serve --dev