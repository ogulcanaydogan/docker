# Cron Runner

Simple container to run scheduled tasks using cron.

## Quick Start

```bash
docker run -d \
  -e CRON_SCHEDULE="0 * * * *" \
  -e CRON_COMMAND="echo 'Hello every hour'" \
  ogulcanaydogan/cron-runner
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `CRON_SCHEDULE` | Cron expression | `* * * * *` |
| `CRON_COMMAND` | Command to run (required) | - |
| `RUN_ON_STARTUP` | Run once at startup | `false` |

## Cron Expression Format

```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 6)
│ │ │ │ │
* * * * *
```

## Examples

```bash
# Every 5 minutes
docker run -d -e CRON_SCHEDULE="*/5 * * * *" -e CRON_COMMAND="curl http://api/ping" ogulcanaydogan/cron-runner

# Daily at midnight
docker run -d -e CRON_SCHEDULE="0 0 * * *" -e CRON_COMMAND="/scripts/backup.sh" -v ./scripts:/scripts ogulcanaydogan/cron-runner

# Every Monday at 9am
docker run -d -e CRON_SCHEDULE="0 9 * * 1" -e CRON_COMMAND="echo 'Weekly report'" ogulcanaydogan/cron-runner
```

## Docker Compose Example

```yaml
services:
  cron:
    image: ogulcanaydogan/cron-runner
    environment:
      - CRON_SCHEDULE=0 2 * * *
      - CRON_COMMAND=curl -X POST http://app:3000/cleanup
      - RUN_ON_STARTUP=true
```

## License

MIT
