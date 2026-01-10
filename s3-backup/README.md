# S3 Backup

Backup files and directories to Amazon S3.

## Quick Start

```bash
docker run \
  -e S3_BUCKET=my-backups \
  -e AWS_ACCESS_KEY_ID=xxx \
  -e AWS_SECRET_ACCESS_KEY=xxx \
  -v /data/to/backup:/data \
  ogulcanaydogan/s3-backup
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `S3_BUCKET` | S3 bucket name (required) | - |
| `S3_PREFIX` | S3 key prefix | `backups` |
| `BACKUP_SOURCE` | Directory to backup | `/data` |
| `BACKUP_NAME` | Backup file prefix | `backup` |
| `CRON_SCHEDULE` | Cron schedule (optional) | - |
| `AWS_REGION` | AWS region | `us-east-1` |
| `AWS_ACCESS_KEY_ID` | AWS access key | - |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | - |

## One-Time Backup

```bash
docker run --rm \
  -e S3_BUCKET=my-backups \
  -e BACKUP_NAME=myapp \
  -v ./data:/data \
  ogulcanaydogan/s3-backup
```

## Scheduled Backups

```bash
docker run -d \
  -e S3_BUCKET=my-backups \
  -e CRON_SCHEDULE="0 2 * * *" \
  -v ./data:/data \
  ogulcanaydogan/s3-backup
```

## Docker Compose Example

```yaml
services:
  backup:
    image: ogulcanaydogan/s3-backup
    environment:
      - S3_BUCKET=my-backups
      - S3_PREFIX=app-backups
      - BACKUP_NAME=myapp
      - CRON_SCHEDULE=0 */6 * * *
      - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
    volumes:
      - app-data:/data:ro

volumes:
  app-data:
```

## Backup File Format

Backups are stored as: `s3://bucket/prefix/name-YYYYMMDD-HHMMSS.tar.gz`

## License

MIT
