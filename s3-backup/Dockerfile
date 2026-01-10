FROM alpine:3.19

RUN apk add --no-cache bash aws-cli tar gzip

COPY backup.sh /backup.sh
RUN chmod +x /backup.sh

ENV S3_BUCKET=""
ENV S3_PREFIX="backups"
ENV BACKUP_SOURCE="/data"
ENV BACKUP_NAME="backup"
ENV CRON_SCHEDULE=""
ENV AWS_REGION="us-east-1"

VOLUME ["/data"]

ENTRYPOINT ["/backup.sh"]
