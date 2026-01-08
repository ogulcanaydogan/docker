# healthcheck

Universal HTTP and TCP health check tool for containers and services.

## Features

- HTTP/HTTPS health checks with customizable expectations
- TCP port connectivity checks
- Configurable timeout and retries
- Response body validation
- Custom headers and request body support
- Quiet mode for scripting
- Exit codes for CI/CD integration

## Quick Start

```bash
docker pull ogulcanaydogan/healthcheck
```

## Usage

### HTTP Health Check

```bash
# Basic HTTP check
docker run --rm ogulcanaydogan/healthcheck http://example.com/health

# With custom status code expectation
docker run --rm ogulcanaydogan/healthcheck -s 201 http://api.example.com/status

# Check response contains specific text
docker run --rm ogulcanaydogan/healthcheck --contains '"status":"ok"' http://localhost/api
```

### TCP Port Check

```bash
# Check if PostgreSQL is accepting connections
docker run --rm --network host ogulcanaydogan/healthcheck --tcp localhost:5432

# Check Redis
docker run --rm --network host ogulcanaydogan/healthcheck --tcp localhost:6379
```

### With Retries

```bash
# Retry 5 times with 2 second intervals
docker run --rm ogulcanaydogan/healthcheck -r 5 -i 2 http://localhost:8080/health
```

### POST Request with Headers

```bash
docker run --rm ogulcanaydogan/healthcheck \
  -m POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer token123" \
  -d '{"test": true}' \
  http://localhost/api/check
```

## Options

| Option | Short | Default | Description |
|--------|-------|---------|-------------|
| `--timeout` | `-t` | `5` | Connection timeout in seconds |
| `--retries` | `-r` | `1` | Number of retry attempts |
| `--interval` | `-i` | `1` | Seconds between retries |
| `--status` | `-s` | `200` | Expected HTTP status code |
| `--method` | `-m` | `GET` | HTTP method |
| `--header` | `-H` | - | HTTP header (repeatable) |
| `--data` | `-d` | - | Request body |
| `--tcp` | | - | Use TCP mode |
| `--contains` | | - | Response must contain text |
| `--verbose` | `-v` | - | Show detailed output |
| `--quiet` | `-q` | - | Suppress all output |
| `--help` | `-h` | - | Show help message |

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Health check passed |
| `1` | Health check failed |
| `2` | Invalid arguments |

## Docker Compose Health Check

```yaml
version: '3.8'

services:
  api:
    image: myapp
    healthcheck:
      test: ["CMD", "docker", "run", "--rm", "--network", "host", "ogulcanaydogan/healthcheck", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
```

Or use as sidecar:

```yaml
version: '3.8'

services:
  api:
    image: myapp

  healthcheck:
    image: ogulcanaydogan/healthcheck
    command: ["-r", "30", "-i", "10", "http://api:8080/health"]
    depends_on:
      - api
```

## Kubernetes Probes

Use in init container or sidecar:

```yaml
apiVersion: v1
kind: Pod
spec:
  initContainers:
  - name: wait-for-db
    image: ogulcanaydogan/healthcheck
    command: ["healthcheck", "--tcp", "-r", "30", "-i", "2", "postgres:5432"]

  containers:
  - name: app
    image: myapp
    livenessProbe:
      exec:
        command:
        - healthcheck
        - http://localhost:8080/health
      initialDelaySeconds: 5
      periodSeconds: 10
```

## CI/CD Integration

### GitHub Actions

```yaml
- name: Wait for service
  run: |
    docker run --rm --network host ogulcanaydogan/healthcheck \
      -r 30 -i 2 http://localhost:8080/health
```

### GitLab CI

```yaml
test:
  services:
    - postgres:16
  script:
    - docker run --rm ogulcanaydogan/healthcheck --tcp -r 30 postgres:5432
    - npm test
```

## Shell Script Integration

```bash
#!/bin/bash

# Wait for services before starting
echo "Waiting for database..."
docker run --rm --network host ogulcanaydogan/healthcheck --tcp -r 30 localhost:5432

echo "Waiting for Redis..."
docker run --rm --network host ogulcanaydogan/healthcheck --tcp -r 30 localhost:6379

echo "Waiting for API..."
docker run --rm --network host ogulcanaydogan/healthcheck -r 30 -i 2 http://localhost:8080/health

echo "All services ready!"
```

## Common Use Cases

### Database Readiness

```bash
# PostgreSQL
healthcheck --tcp postgres:5432

# MySQL
healthcheck --tcp mysql:3306

# MongoDB
healthcheck --tcp mongo:27017

# Redis
healthcheck --tcp redis:6379
```

### API Readiness

```bash
# REST API with JSON response
healthcheck --contains '"status":"healthy"' http://api/health

# GraphQL
healthcheck -m POST \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __typename }"}' \
  http://api/graphql

# With authentication
healthcheck -H "Authorization: Bearer $TOKEN" http://api/health
```

### Service Dependencies

```bash
# Wait for multiple services
healthcheck --tcp db:5432 && \
healthcheck --tcp redis:6379 && \
healthcheck http://api:8080/health && \
echo "All services ready"
```

## Building

```bash
docker build -t ogulcanaydogan/healthcheck .
```

## License

MIT License
