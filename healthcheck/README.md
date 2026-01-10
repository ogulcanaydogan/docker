# Healthcheck

Lightweight health check sidecar for monitoring container health.

## Quick Start

```bash
docker run -d -p 8080:8080 ogulcanaydogan/healthcheck
```

## Features

- HTTP health endpoint
- TCP port checking
- Custom health scripts
- Prometheus metrics

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Health check port | `8080` |
| `CHECK_URL` | URL to check | None |
| `CHECK_TCP` | TCP host:port to check | None |
| `INTERVAL` | Check interval (seconds) | `10` |

## Docker Compose Example

```yaml
services:
  app:
    image: myapp

  healthcheck:
    image: ogulcanaydogan/healthcheck
    environment:
      - CHECK_URL=http://app:3000/health
      - CHECK_TCP=db:5432
    ports:
      - "8080:8080"
```

## Endpoints

- `GET /health` - Returns health status
- `GET /metrics` - Prometheus metrics

## License

MIT
