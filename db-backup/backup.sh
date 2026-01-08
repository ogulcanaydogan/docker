#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Default values
BACKUP_DIR="${BACKUP_DIR:-/backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS="${RETENTION_DAYS:-7}"
COMPRESS="${COMPRESS:-true}"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Function to upload to S3
upload_to_s3() {
    local file=$1
    if [ -n "$S3_BUCKET" ]; then
        log_info "Uploading to S3: s3://$S3_BUCKET/$S3_PREFIX"
        aws s3 cp "$file" "s3://$S3_BUCKET/${S3_PREFIX:-backups}/$(basename $file)"
        log_info "S3 upload complete"
    fi
}

# Function to upload to GCS
upload_to_gcs() {
    local file=$1
    if [ -n "$GCS_BUCKET" ]; then
        log_info "Uploading to GCS: gs://$GCS_BUCKET/$GCS_PREFIX"
        gsutil cp "$file" "gs://$GCS_BUCKET/${GCS_PREFIX:-backups}/$(basename $file)"
        log_info "GCS upload complete"
    fi
}

# Function to clean old backups
cleanup_old_backups() {
    if [ "$RETENTION_DAYS" -gt 0 ]; then
        log_info "Cleaning backups older than $RETENTION_DAYS days"
        find "$BACKUP_DIR" -type f -mtime +$RETENTION_DAYS -delete 2>/dev/null || true
    fi
}

# PostgreSQL backup
backup_postgres() {
    log_info "Starting PostgreSQL backup..."

    local host="${POSTGRES_HOST:-localhost}"
    local port="${POSTGRES_PORT:-5432}"
    local user="${POSTGRES_USER:-postgres}"
    local db="${POSTGRES_DB:-postgres}"
    local filename="postgres_${db}_${TIMESTAMP}.sql"

    export PGPASSWORD="${POSTGRES_PASSWORD}"

    if [ "$COMPRESS" = "true" ]; then
        pg_dump -h "$host" -p "$port" -U "$user" -d "$db" | gzip > "$BACKUP_DIR/${filename}.gz"
        filename="${filename}.gz"
    else
        pg_dump -h "$host" -p "$port" -U "$user" -d "$db" > "$BACKUP_DIR/$filename"
    fi

    log_info "PostgreSQL backup complete: $filename"
    upload_to_s3 "$BACKUP_DIR/$filename"
    upload_to_gcs "$BACKUP_DIR/$filename"
}

# MySQL backup
backup_mysql() {
    log_info "Starting MySQL backup..."

    local host="${MYSQL_HOST:-localhost}"
    local port="${MYSQL_PORT:-3306}"
    local user="${MYSQL_USER:-root}"
    local db="${MYSQL_DB:-mysql}"
    local filename="mysql_${db}_${TIMESTAMP}.sql"

    if [ "$COMPRESS" = "true" ]; then
        mysqldump -h "$host" -P "$port" -u "$user" -p"${MYSQL_PASSWORD}" "$db" | gzip > "$BACKUP_DIR/${filename}.gz"
        filename="${filename}.gz"
    else
        mysqldump -h "$host" -P "$port" -u "$user" -p"${MYSQL_PASSWORD}" "$db" > "$BACKUP_DIR/$filename"
    fi

    log_info "MySQL backup complete: $filename"
    upload_to_s3 "$BACKUP_DIR/$filename"
    upload_to_gcs "$BACKUP_DIR/$filename"
}

# MongoDB backup
backup_mongodb() {
    log_info "Starting MongoDB backup..."

    local host="${MONGO_HOST:-localhost}"
    local port="${MONGO_PORT:-27017}"
    local db="${MONGO_DB:-}"
    local filename="mongodb_${db:-all}_${TIMESTAMP}"

    local uri="${MONGO_URI:-mongodb://$host:$port}"

    if [ -n "$db" ]; then
        mongodump --uri="$uri" --db="$db" --out="$BACKUP_DIR/$filename"
    else
        mongodump --uri="$uri" --out="$BACKUP_DIR/$filename"
    fi

    if [ "$COMPRESS" = "true" ]; then
        tar -czf "$BACKUP_DIR/${filename}.tar.gz" -C "$BACKUP_DIR" "$filename"
        rm -rf "$BACKUP_DIR/$filename"
        filename="${filename}.tar.gz"
    fi

    log_info "MongoDB backup complete: $filename"
    upload_to_s3 "$BACKUP_DIR/$filename"
    upload_to_gcs "$BACKUP_DIR/$filename"
}

# Redis backup
backup_redis() {
    log_info "Starting Redis backup..."

    local host="${REDIS_HOST:-localhost}"
    local port="${REDIS_PORT:-6379}"
    local filename="redis_${TIMESTAMP}.rdb"

    # Trigger BGSAVE and wait for completion
    if [ -n "$REDIS_PASSWORD" ]; then
        redis-cli -h "$host" -p "$port" -a "$REDIS_PASSWORD" BGSAVE
        sleep 2
        redis-cli -h "$host" -p "$port" -a "$REDIS_PASSWORD" --rdb "$BACKUP_DIR/$filename"
    else
        redis-cli -h "$host" -p "$port" BGSAVE
        sleep 2
        redis-cli -h "$host" -p "$port" --rdb "$BACKUP_DIR/$filename"
    fi

    if [ "$COMPRESS" = "true" ]; then
        gzip "$BACKUP_DIR/$filename"
        filename="${filename}.gz"
    fi

    log_info "Redis backup complete: $filename"
    upload_to_s3 "$BACKUP_DIR/$filename"
    upload_to_gcs "$BACKUP_DIR/$filename"
}

# Main execution
main() {
    log_info "=== Database Backup Tool ==="
    log_info "Timestamp: $TIMESTAMP"
    log_info "Backup directory: $BACKUP_DIR"

    case "${DB_TYPE:-}" in
        postgres|postgresql)
            backup_postgres
            ;;
        mysql|mariadb)
            backup_mysql
            ;;
        mongodb|mongo)
            backup_mongodb
            ;;
        redis)
            backup_redis
            ;;
        *)
            log_error "Unknown or missing DB_TYPE. Supported: postgres, mysql, mongodb, redis"
            exit 1
            ;;
    esac

    cleanup_old_backups
    log_info "=== Backup completed successfully ==="
}

main "$@"
