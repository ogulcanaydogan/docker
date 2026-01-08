FROM alpine:3.19

LABEL maintainer="Ogulcan Aydogan"
LABEL description="Self-signed SSL certificate generator for local development"

# Install OpenSSL
RUN apk add --no-cache openssl bash

# Copy generator script
COPY generate.sh /usr/local/bin/ssl-gen
RUN chmod +x /usr/local/bin/ssl-gen

# Create output directory
RUN mkdir -p /certs

WORKDIR /certs

# Default environment variables
ENV DOMAIN=localhost \
    DAYS=365 \
    KEY_SIZE=2048 \
    OUTPUT_DIR=/certs \
    CERT_NAME=server

ENTRYPOINT ["/usr/local/bin/ssl-gen"]
