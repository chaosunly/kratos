#!/bin/sh
set -e

# Ensure URLs have proper protocol prefix
if [ -n "$KRATOS_PUBLIC_URL" ] && ! echo "$KRATOS_PUBLIC_URL" | grep -qE '^https?://'; then
  export KRATOS_PUBLIC_URL="https://${KRATOS_PUBLIC_URL}"
fi

if [ -n "$KRATOS_ADMIN_URL" ] && ! echo "$KRATOS_ADMIN_URL" | grep -qE '^https?://'; then
  export KRATOS_ADMIN_URL="https://${KRATOS_ADMIN_URL}"
fi

if [ -n "$DEFAULT_RETURN_URL" ] && ! echo "$DEFAULT_RETURN_URL" | grep -qE '^https?://'; then
  export DEFAULT_RETURN_URL="https://${DEFAULT_RETURN_URL}"
fi

if [ -n "$ALLOWED_RETURN_URL" ] && ! echo "$ALLOWED_RETURN_URL" | grep -qE '^https?://'; then
  export ALLOWED_RETURN_URL="https://${ALLOWED_RETURN_URL}"
fi

if [ -n "$KRATOS_UI_URL" ] && ! echo "$KRATOS_UI_URL" | grep -qE '^https?://'; then
  export KRATOS_UI_URL="https://${KRATOS_UI_URL}"
fi

# Substitute environment variables in the config file
envsubst < /etc/kratos/kratos.yml > /tmp/kratos.yml

# Run DB migrations
kratos -c /tmp/kratos.yml migrate sql -e --yes

# Start Kratos
kratos -c /tmp/kratos.yml serve