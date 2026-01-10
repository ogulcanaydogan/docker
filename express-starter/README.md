# Express Starter

Production-ready Express.js boilerplate with best practices baked in.

## Quick Start

```bash
docker run -d -p 3000:3000 ogulcanaydogan/express-starter
```

## Features

- Express.js with structured routing
- Error handling middleware
- Health check endpoint
- Environment configuration
- Security headers (Helmet)
- CORS enabled

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `3000` |
| `NODE_ENV` | Environment | `production` |

## Endpoints

- `GET /` - Welcome message
- `GET /health` - Health check

## Extend

```dockerfile
FROM ogulcanaydogan/express-starter
COPY ./src /app/src
```

## License

MIT
