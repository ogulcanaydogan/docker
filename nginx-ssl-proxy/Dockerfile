FROM nginx:alpine

RUN apk add --no-cache certbot certbot-nginx bash openssl

COPY entrypoint.sh /entrypoint.sh
COPY nginx.conf.template /etc/nginx/nginx.conf.template
RUN chmod +x /entrypoint.sh

ENV UPSTREAM_HOST="app"
ENV UPSTREAM_PORT="3000"
ENV SERVER_NAME="localhost"
ENV SSL_EMAIL=""
ENV AUTO_SSL="false"

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
