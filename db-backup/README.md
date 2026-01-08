# db-backup

Universal database backup tool supporting PostgreSQL, MySQL, MongoDB, and Redis with cloud storage upload capabilities.

## Features

- Support for multiple databases: PostgreSQL, MySQL, MongoDB, Redis
- Automatic compression (gzip)
- Upload to AWS S3 or Google Cloud Storage
- Configurable retention policy
- Lightweight Alpine-based image

## Quick Start

```bash
docker pull ogulcanaydogan/db-backup
```

## Usage

### PostgreSQL

```bash
docker run --rm \
  -e DB_TYPE=postgres \
  -e POSTGRES_HOST=your-host \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=mydb \
  -v $(pwd)/backups:/backups \
  ogulcanaydogan/db-backup
```

### MySQL

```bash
docker run --rm \
  -e DB_TYPE=mysql \
  -e MYSQL_HOST=your-host \
  -e MYSQL_USER=root \
  -e MYSQL_PASSWORD=secret \
  -e MYSQL_DB=mydb \
  -v $(pwd)/backups:/backups \
  ogulcanaydogan/db-backup
```

### MongoDB

```bash
docker run --rm \
  -e DB_TYPE=mongodb \
  -e MONGO_HOST=your-host \
  -e MONGO_DB=mydb \
  -v $(pwd)/backups:/backups \
  ogulcanaydogan/db-backup

# Or using connection URI
docker run --rm \
  -e DB_TYPE=mongodb \
  -e MONGO_URI="mongodb://user:pass@host:27017" \
  -e MONGO_DB=mydb \
  -v $(pwd)/backups:/backups \
  ogulcanaydogan/db-backup
```

### Redis

```bash
docker run --rm \
  -e DB_TYPE=redis \
  -e REDIS_HOST=your-host \
  -e REDIS_PASSWORD=secret \
  -v $(pwd)/backups:/backups \
  ogulcanaydogan/db-backup
```

## Cloud Storage Upload

### AWS S3

```bash
docker run --rm \
  -e DB_TYPE=postgres \
  -e POSTGRES_HOST=your-host \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=mydb \
  -e S3_BUCKET=my-backup-bucket \
  -e S3_PREFIX=database-backups \
  -e AWS_ACCESS_KEY_ID=your-key \
  -e AWS_SECRET_ACCESS_KEY=your-secret \
  -e AWS_DEFAULT_REGION=us-east-1 \
  ogulcanaydogan/db-backup
```

### Google Cloud Storage

```bash
docker run --rm \
  -e DB_TYPE=postgres \
  -e POSTGRES_HOST=your-host \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=mydb \
  -e GCS_BUCKET=my-backup-bucket \
  -e GCS_PREFIX=database-backups \
  -v /path/to/service-account.json:/gcp-key.json \
  -e GOOGLE_APPLICATION_CREDENTIALS=/gcp-key.json \
  ogulcanaydogan/db-backup
```

## Environment Variables

### General

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_TYPE` | *required* | Database type: `postgres`, `mysql`, `mongodb`, `redis` |
| `BACKUP_DIR` | `/backups` | Directory to store backups |
| `RETENTION_DAYS` | `7` | Delete backups older than N days (0 to disable) |
| `COMPRESS` | `true` | Compress backups with gzip |

### PostgreSQL

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_HOST` | `localhost` | Database host |
| `POSTGRES_PORT` | `5432` | Database port |
| `POSTGRES_USER` | `postgres` | Database user |
| `POSTGRES_PASSWORD` | - | Database password |
| `POSTGRES_DB` | `postgres` | Database name |

### MySQL

| Variable | Default | Description |
|----------|---------|-------------|
| `MYSQL_HOST` | `localhost` | Database host |
| `MYSQL_PORT` | `3306` | Database port |
| `MYSQL_USER` | `root` | Database user |
| `MYSQL_PASSWORD` | - | Database password |
| `MYSQL_DB` | `mysql` | Database name |

### MongoDB

| Variable | Default | Description |
|----------|---------|-------------|
| `MONGO_HOST` | `localhost` | Database host |
| `MONGO_PORT` | `27017` | Database port |
| `MONGO_URI` | - | Full connection URI (overrides host/port) |
| `MONGO_DB` | - | Database name (empty = all databases) |

### Redis

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_HOST` | `localhost` | Redis host |
| `REDIS_PORT` | `6379` | Redis port |
| `REDIS_PASSWORD` | - | Redis password |

### Cloud Storage

| Variable | Description |
|----------|-------------|
| `S3_BUCKET` | AWS S3 bucket name |
| `S3_PREFIX` | S3 key prefix (default: `backups`) |
| `GCS_BUCKET` | Google Cloud Storage bucket name |
| `GCS_PREFIX` | GCS object prefix (default: `backups`) |

## Docker Compose Example

```yaml
version: '3.8'

services:
  db-backup:
    image: ogulcanaydogan/db-backup
    environment:
      - DB_TYPE=postgres
      - POSTGRES_HOST=db
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=secret
      - POSTGRES_DB=myapp
      - RETENTION_DAYS=14
    volumes:
      - ./backups:/backups
    depends_on:
      - db

  db:
    image: postgres:16
    environment:
      - POSTGRES_PASSWORD=secret
      - POSTGRES_DB=myapp
```

## Kubernetes CronJob Example

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: db-backup
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: ogulcanaydogan/db-backup
            env:
            - name: DB_TYPE
              value: postgres
            - name: POSTGRES_HOST
              value: postgres-service
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-secrets
                  key: password
            - name: S3_BUCKET
              value: my-backup-bucket
          restartPolicy: OnFailure
```

## Building

```bash
docker build -t ogulcanaydogan/db-backup .
```

## License

MIT License
