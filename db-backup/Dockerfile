FROM alpine:3.19

LABEL maintainer="Ogulcan Aydogan"
LABEL description="Universal database backup tool supporting PostgreSQL, MySQL, MongoDB, and Redis"

# Install database clients and cloud tools
RUN apk add --no-cache \
    bash \
    postgresql16-client \
    mysql-client \
    mongodb-tools \
    redis \
    aws-cli \
    python3 \
    py3-pip \
    gzip \
    tar \
    ca-certificates \
    && pip3 install --no-cache-dir --break-system-packages gsutil

# Create backup directory
RUN mkdir -p /backups

# Copy backup script
COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

# Set working directory
WORKDIR /backups

# Default environment variables
ENV BACKUP_DIR=/backups \
    RETENTION_DAYS=7 \
    COMPRESS=true

ENTRYPOINT ["/usr/local/bin/backup.sh"]
