FROM alpine:3.19

RUN apk add --no-cache postfix postfix-pcre ca-certificates bash

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV RELAY_HOST=""
ENV RELAY_PORT="587"
ENV RELAY_USER=""
ENV RELAY_PASSWORD=""
ENV ALLOWED_NETWORKS="10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"

EXPOSE 25

ENTRYPOINT ["/entrypoint.sh"]
