#!/bin/bash
set -e

SSL_DIR="/etc/nginx/ssl"
mkdir -p "$SSL_DIR"

# Generate nginx config
envsubst '${UPSTREAM_HOST} ${UPSTREAM_PORT} ${SERVER_NAME}' \
    < /etc/nginx/nginx.conf.template \
    > /etc/nginx/nginx.conf

if [ "$AUTO_SSL" = "true" ] && [ -n "$SSL_EMAIL" ]; then
    echo "Requesting Let's Encrypt certificate for $SERVER_NAME..."

    # Start nginx temporarily for ACME challenge
    nginx &
    sleep 2

    certbot --nginx -d "$SERVER_NAME" \
        --non-interactive \
        --agree-tos \
        --email "$SSL_EMAIL" \
        --redirect

    # Stop temporary nginx
    nginx -s stop
    sleep 1

    # Setup auto-renewal
    echo "0 0 * * * certbot renew --quiet" | crontab -

else
    # Generate self-signed certificate
    if [ ! -f "$SSL_DIR/server.crt" ]; then
        echo "Generating self-signed certificate..."
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout "$SSL_DIR/server.key" \
            -out "$SSL_DIR/server.crt" \
            -subj "/CN=$SERVER_NAME"
    fi
fi

echo "Starting nginx..."
exec nginx -g "daemon off;"
