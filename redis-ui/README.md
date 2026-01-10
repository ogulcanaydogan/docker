# Redis UI

Simple web UI for browsing and managing Redis data.

## Quick Start

```bash
docker run -d \
  -e REDIS_HOST=localhost \
  -p 8080:8080 \
  ogulcanaydogan/redis-ui
```

Open http://localhost:8080

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `REDIS_HOST` | Redis host | `redis` |
| `REDIS_PORT` | Redis port | `6379` |
| `REDIS_PASSWORD` | Redis password | - |
| `PORT` | Web UI port | `8080` |

## Features

- Browse keys with pattern matching
- View all data types (string, list, set, hash, zset)
- Add new keys
- Delete keys
- View TTL
- Server stats (memory, clients, version)

## Docker Compose Example

```yaml
services:
  redis:
    image: redis:alpine

  redis-ui:
    image: ogulcanaydogan/redis-ui
    environment:
      - REDIS_HOST=redis
    ports:
      - "8080:8080"
    depends_on:
      - redis
```

## API Endpoints

- `GET /api/keys?pattern=*` - List keys
- `GET /api/key/:key` - Get key value
- `POST /api/key` - Set key value
- `DELETE /api/key/:key` - Delete key
- `GET /api/info` - Server info
- `GET /health` - Health check

## License

MIT
