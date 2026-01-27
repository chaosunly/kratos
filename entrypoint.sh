#!/bin/sh
set -e

# Railway injects PORT dynamically
export SERVE_PUBLIC_PORT="${PORT:-4433}"

# Run DB migrations
kratos -c /etc/kratos/kratos.yml migrate sql -e --yes

# Start Kratos
kratos -c /etc/kratos/kratos.yml serve