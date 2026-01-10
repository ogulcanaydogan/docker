# DB Backup

Automated database backup utility supporting PostgreSQL and MySQL.

## Quick Start

```bash
docker run -e DB_TYPE=postgres -e DB_HOST=mydb -e DB_NAME=myapp ogulcanaydogan/db-backup
```

## Supported Databases

- PostgreSQL
- MySQL / MariaDB

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `DB_TYPE` | `postgres` or `mysql` | Yes |
| `DB_HOST` | Database host | Yes |
| `DB_PORT` | Database port | No |
| `DB_NAME` | Database name | Yes |
| `DB_USER` | Username | Yes |
| `DB_PASSWORD` | Password | Yes |
| `BACKUP_DIR` | Output directory | `/backups` |

## Save Backups Locally

```bash
docker run -v $(pwd)/backups:/backups \
  -e DB_TYPE=postgres \
  -e DB_HOST=localhost \
  -e DB_NAME=myapp \
  -e DB_USER=postgres \
  -e DB_PASSWORD=secret \
  ogulcanaydogan/db-backup
```

## Scheduled Backups (with cron)

```bash
docker run -d -e CRON_SCHEDULE="0 2 * * *" \
  -e DB_TYPE=mysql \
  -e DB_HOST=mydb \
  -e DB_NAME=app \
  -e DB_USER=root \
  -e DB_PASSWORD=secret \
  ogulcanaydogan/db-backup
```

## License

MIT
