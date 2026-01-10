# Log Exporter

Export container logs to S3 or CloudWatch.

## Quick Start (S3)

```bash
docker run -d \
  -e S3_BUCKET=my-logs \
  -e AWS_ACCESS_KEY_ID=xxx \
  -e AWS_SECRET_ACCESS_KEY=xxx \
  -v /var/log/app:/logs \
  ogulcanaydogan/log-exporter
```

## Quick Start (CloudWatch)

```bash
docker run -d \
  -e EXPORT_TYPE=cloudwatch \
  -e CW_LOG_GROUP=/myapp/logs \
  -v /var/log/app:/logs \
  ogulcanaydogan/log-exporter
```

## Environment Variables

### Common

| Variable | Description | Default |
|----------|-------------|---------|
| `LOG_PATH` | Directory to watch | `/logs` |
| `EXPORT_TYPE` | `s3` or `cloudwatch` | `s3` |
| `BATCH_SIZE` | Logs per batch | `100` |
| `FLUSH_INTERVAL` | Flush interval (seconds) | `60` |
| `AWS_REGION` | AWS region | `us-east-1` |

### S3

| Variable | Description | Default |
|----------|-------------|---------|
| `S3_BUCKET` | S3 bucket (required) | - |
| `S3_PREFIX` | S3 key prefix | `logs` |

### CloudWatch

| Variable | Description | Default |
|----------|-------------|---------|
| `CW_LOG_GROUP` | CloudWatch log group | `/app/logs` |
| `CW_LOG_STREAM` | CloudWatch log stream | `default` |

## Docker Compose Example

```yaml
services:
  app:
    image: myapp
    volumes:
      - logs:/var/log/app

  log-exporter:
    image: ogulcanaydogan/log-exporter
    environment:
      - S3_BUCKET=my-logs
      - FLUSH_INTERVAL=30
    volumes:
      - logs:/logs:ro

volumes:
  logs:
```

## Log File Format

Watches for `*.log` files and exports each line as a separate log entry.

## License

MIT
