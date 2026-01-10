#!/bin/bash
set -e

if [ -z "$RELAY_HOST" ]; then
    echo "Error: RELAY_HOST environment variable is required"
    exit 1
fi

echo "Configuring Postfix SMTP relay..."

# Configure relay host
postconf -e "relayhost = [$RELAY_HOST]:$RELAY_PORT"
postconf -e "smtp_use_tls = yes"
postconf -e "smtp_tls_security_level = encrypt"
postconf -e "smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt"

# Configure authentication if credentials provided
if [ -n "$RELAY_USER" ] && [ -n "$RELAY_PASSWORD" ]; then
    echo "Configuring SMTP authentication..."
    postconf -e "smtp_sasl_auth_enable = yes"
    postconf -e "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd"
    postconf -e "smtp_sasl_security_options = noanonymous"

    echo "[$RELAY_HOST]:$RELAY_PORT $RELAY_USER:$RELAY_PASSWORD" > /etc/postfix/sasl_passwd
    postmap /etc/postfix/sasl_passwd
    chmod 600 /etc/postfix/sasl_passwd*
fi

# Configure allowed networks
postconf -e "mynetworks = 127.0.0.0/8 $ALLOWED_NETWORKS"
postconf -e "inet_interfaces = all"
postconf -e "inet_protocols = ipv4"

# Disable local delivery
postconf -e "mydestination = "
postconf -e "local_transport = error:local delivery disabled"

echo "Starting Postfix..."
exec postfix start-fg
