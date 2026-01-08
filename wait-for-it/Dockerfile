FROM alpine:3.19

LABEL maintainer="Ogulcan Aydogan"
LABEL description="Wait for services to be ready before starting your application"

# Install required tools
RUN apk add --no-cache \
    bash \
    netcat-openbsd

# Copy wait script
COPY wait-for-it.sh /usr/local/bin/wait-for-it
RUN chmod +x /usr/local/bin/wait-for-it

ENTRYPOINT ["/usr/local/bin/wait-for-it"]
CMD ["--help"]
