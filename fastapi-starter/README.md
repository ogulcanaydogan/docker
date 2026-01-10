# FastAPI Starter

Production-ready FastAPI boilerplate with async support.

## Quick Start

```bash
docker run -d -p 8000:8000 ogulcanaydogan/fastapi-starter
```

## Features

- FastAPI with async/await
- Auto-generated OpenAPI docs
- Health check endpoint
- CORS middleware
- Pydantic validation
- Uvicorn ASGI server

## Endpoints

- `GET /` - Welcome message
- `GET /health` - Health check
- `GET /docs` - Swagger UI
- `GET /redoc` - ReDoc documentation

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `8000` |
| `WORKERS` | Uvicorn workers | `1` |
| `LOG_LEVEL` | Logging level | `info` |

## Extend

```dockerfile
FROM ogulcanaydogan/fastapi-starter
COPY ./app /app/app
```

## License

MIT
