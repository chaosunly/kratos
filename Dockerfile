FROM oryd/kratos:v25.4.0

# Install envsubst for config variable substitution
USER root
RUN apk add --no-cache gettext
USER ory

WORKDIR /etc/kratos

COPY kratos.yml /etc/kratos/kratos.yml
COPY identity.schema.json /etc/kratos/identity.schema.json
COPY simplelogin.jsonnet /etc/kratos/simplelogin.jsonnet
COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]