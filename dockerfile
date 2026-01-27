FROM oryd/kratos:v25.4.0

WORKDIR /etc/kratos

COPY kratos.yml /etc/kratos/kratos.yml
COPY identity.schema.json /etc/kratos/identity.schema.json
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 4433

ENTRYPOINT ["/entrypoint.sh"]