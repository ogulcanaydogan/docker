FROM alpine:3.19

LABEL maintainer="Ogulcan Aydogan"
LABEL description="Universal HTTP/TCP health check tool"

# Install required tools
RUN apk add --no-cache \
    bash \
    curl \
    netcat-openbsd \
    ca-certificates

# Copy health check script
COPY healthcheck.sh /usr/local/bin/healthcheck
RUN chmod +x /usr/local/bin/healthcheck

ENTRYPOINT ["/usr/local/bin/healthcheck"]
CMD ["--help"]
