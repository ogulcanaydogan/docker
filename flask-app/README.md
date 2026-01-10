# Flask App

Simple Flask application template for quick deployments.

## Quick Start

```bash
docker run -d -p 5000:5000 ogulcanaydogan/flask-app
```

## Features

- Flask with production-ready config
- Health check endpoint
- Gunicorn WSGI server
- Minimal footprint

## Endpoints

- `GET /` - Welcome page
- `GET /health` - Health check

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `5000` |
| `WORKERS` | Gunicorn workers | `2` |
| `DEBUG` | Debug mode | `false` |

## Extend

```dockerfile
FROM ogulcanaydogan/flask-app
COPY ./app /app
```

## License

MIT
