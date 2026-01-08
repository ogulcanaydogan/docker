# fastapi-starter

Production-ready FastAPI template with best practices, health checks, and Docker support.

## Features

- FastAPI 0.109+ with Pydantic v2
- Health check endpoints (Kubernetes-ready)
- CORS middleware configured
- Environment-based configuration
- Non-root Docker user
- Docker Compose ready
- OpenAPI documentation

## Quick Start

```bash
docker pull ogulcanaydogan/fastapi-starter
docker run -p 8000:8000 ogulcanaydogan/fastapi-starter
```

Open http://localhost:8000/docs for interactive API documentation.

## Usage

### With Docker Compose

```bash
# Clone or copy the fastapi-starter directory
cd fastapi-starter

# Copy environment file
cp .env.example .env

# Start the application
docker compose up -d

# View logs
docker compose logs -f
```

### Development Mode

```bash
# Install dependencies
pip install -r requirements.txt

# Run with auto-reload
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Project Structure

```
fastapi-starter/
├── app/
│   ├── __init__.py
│   ├── main.py           # Application entry point
│   ├── api/
│   │   ├── __init__.py
│   │   ├── health.py     # Health check endpoints
│   │   └── items.py      # Example CRUD endpoints
│   ├── core/
│   │   ├── __init__.py
│   │   └── config.py     # Configuration management
│   ├── models/           # Database models (SQLAlchemy)
│   └── schemas/          # Pydantic schemas
├── requirements.txt
├── Dockerfile
├── docker-compose.yml
└── .env.example
```

## API Endpoints

### Health Checks

| Endpoint | Description |
|----------|-------------|
| `GET /health` | Basic health check |
| `GET /health/ready` | Readiness probe (Kubernetes) |
| `GET /health/live` | Liveness probe (Kubernetes) |

### Example Items API

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/v1/items` | List items (paginated) |
| `POST` | `/api/v1/items` | Create item |
| `GET` | `/api/v1/items/{id}` | Get item |
| `PATCH` | `/api/v1/items/{id}` | Update item |
| `DELETE` | `/api/v1/items/{id}` | Delete item |

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `APP_NAME` | `FastAPI Starter` | Application name |
| `APP_VERSION` | `1.0.0` | Application version |
| `ENVIRONMENT` | `production` | Environment name |
| `DEBUG` | `false` | Enable debug mode |
| `HOST` | `0.0.0.0` | Server host |
| `PORT` | `8000` | Server port |
| `SECRET_KEY` | `change-me` | Secret key for signing |
| `SHOW_DOCS` | `true` | Show OpenAPI docs |
| `CORS_ORIGINS` | `["*"]` | Allowed CORS origins |
| `DATABASE_URL` | - | Database connection URL |
| `REDIS_URL` | - | Redis connection URL |

## Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fastapi-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: fastapi-app
  template:
    metadata:
      labels:
        app: fastapi-app
    spec:
      containers:
      - name: api
        image: ogulcanaydogan/fastapi-starter
        ports:
        - containerPort: 8000
        env:
        - name: ENVIRONMENT
          value: production
        - name: SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: secret-key
        livenessProbe:
          httpGet:
            path: /health/live
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          limits:
            cpu: "500m"
            memory: "256Mi"
          requests:
            cpu: "100m"
            memory: "128Mi"
---
apiVersion: v1
kind: Service
metadata:
  name: fastapi-app
spec:
  selector:
    app: fastapi-app
  ports:
  - port: 80
    targetPort: 8000
  type: ClusterIP
```

## Adding Database Support

### PostgreSQL with SQLAlchemy

1. Add to `requirements.txt`:
```
sqlalchemy>=2.0.0
asyncpg>=0.29.0
alembic>=1.13.0
```

2. Create `app/core/database.py`:
```python
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

engine = create_async_engine(settings.DATABASE_URL)
AsyncSessionLocal = sessionmaker(engine, class_=AsyncSession)

async def get_db():
    async with AsyncSessionLocal() as session:
        yield session
```

## Production Considerations

1. **Security**: Change `SECRET_KEY` and disable `SHOW_DOCS`
2. **CORS**: Specify exact origins instead of `["*"]`
3. **Scaling**: Increase `WORKERS` based on CPU cores
4. **Monitoring**: Add Prometheus metrics endpoint
5. **Logging**: Configure structured JSON logging

## Building

```bash
docker build -t ogulcanaydogan/fastapi-starter .
```

## License

MIT License
