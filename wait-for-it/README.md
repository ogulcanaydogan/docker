# Wait For It

Wait for services to be available before starting your application.

## Quick Start

```bash
docker run ogulcanaydogan/wait-for-it db:5432
```

## Docker Compose Example

```yaml
services:
  db:
    image: postgres

  app:
    image: myapp
    depends_on:
      wait:
        condition: service_completed_successfully

  wait:
    image: ogulcanaydogan/wait-for-it
    environment:
      - TARGETS=db:5432
      - TIMEOUT=30
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `TARGETS` | Comma-separated host:port pairs | Required |
| `TIMEOUT` | Timeout in seconds | `30` |
| `INTERVAL` | Check interval in seconds | `1` |

## Multiple Services

```bash
docker run -e TARGETS="db:5432,redis:6379,api:8080" ogulcanaydogan/wait-for-it
```

## Exit Codes

- `0` - All services available
- `1` - Timeout reached

## License

MIT
