#!/bin/bash
set -e

if [ -z "$S3_BUCKET" ]; then
    echo "Error: S3_BUCKET environment variable is required"
    exit 1
fi

do_backup() {
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    BACKUP_FILE="/tmp/${BACKUP_NAME}-${TIMESTAMP}.tar.gz"
    S3_PATH="s3://${S3_BUCKET}/${S3_PREFIX}/${BACKUP_NAME}-${TIMESTAMP}.tar.gz"

    echo "[$(date)] Starting backup of $BACKUP_SOURCE"

    # Create tarball
    tar -czf "$BACKUP_FILE" -C "$BACKUP_SOURCE" .

    # Upload to S3
    echo "[$(date)] Uploading to $S3_PATH"
    aws s3 cp "$BACKUP_FILE" "$S3_PATH" --region "$AWS_REGION"

    # Cleanup
    rm -f "$BACKUP_FILE"

    echo "[$(date)] Backup complete: $S3_PATH"
}

# Run once if no cron schedule
if [ -z "$CRON_SCHEDULE" ]; then
    do_backup
    exit 0
fi

# Setup cron job
echo "Setting up cron schedule: $CRON_SCHEDULE"
export -f do_backup
export S3_BUCKET S3_PREFIX BACKUP_SOURCE BACKUP_NAME AWS_REGION

echo "$CRON_SCHEDULE /backup.sh" > /etc/crontabs/root

# Run initial backup
echo "Running initial backup..."
do_backup

# Start cron
echo "Starting cron daemon..."
exec crond -f -l 2
