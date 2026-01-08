# wait-for-it

Wait for services to be available before starting your application. Perfect for Docker Compose and Kubernetes deployments.

## Features

- Wait for multiple services simultaneously
- Sequential or parallel checking
- Configurable timeout and retry interval
- Execute command after services are ready
- Environment variable configuration
- Lightweight Alpine-based image

## Quick Start

```bash
docker pull ogulcanaydogan/wait-for-it
```

## Usage

### Basic Usage

```bash
# Wait for single service
docker run --rm ogulcanaydogan/wait-for-it db:5432

# Wait for multiple services
docker run --rm ogulcanaydogan/wait-for-it db:5432 redis:6379 api:8080
```

### With Command Execution

```bash
# Wait for services, then run command
docker run --rm ogulcanaydogan/wait-for-it db:5432 redis:6379 -- echo "Ready!"

# In your app container
docker run --rm myapp wait-for-it db:5432 -- npm start
```

### Parallel Mode

```bash
# Check all services simultaneously (faster)
docker run --rm ogulcanaydogan/wait-for-it --parallel db:5432 redis:6379 api:8080
```

### With Custom Timeout

```bash
# Wait up to 60 seconds
docker run --rm ogulcanaydogan/wait-for-it -t 60 db:5432

# Wait indefinitely (timeout=0)
docker run --rm ogulcanaydogan/wait-for-it -t 0 db:5432
```

## Options

| Option | Short | Default | Description |
|--------|-------|---------|-------------|
| `--host HOST:PORT` | `-h` | - | Service to wait for (repeatable) |
| `--timeout SECONDS` | `-t` | `30` | Timeout (0 = infinite) |
| `--interval SECONDS` | `-i` | `1` | Check interval |
| `--parallel` | `-p` | - | Check all hosts in parallel |
| `--strict` | `-s` | - | Fail immediately if any host fails |
| `--quiet` | `-q` | - | Suppress output |
| `--verbose` | `-v` | - | Show detailed output |
| `--help` | | - | Show help message |
| `--` | | - | Separator for command to execute |

## Environment Variables

| Variable | Description |
|----------|-------------|
| `WAIT_HOSTS` | Comma-separated list of host:port pairs |
| `WAIT_TIMEOUT` | Timeout in seconds |
| `WAIT_INTERVAL` | Check interval in seconds |
| `WAIT_COMMAND` | Command to run after services are ready |

```bash
docker run --rm \
  -e WAIT_HOSTS=db:5432,redis:6379 \
  -e WAIT_TIMEOUT=60 \
  -e WAIT_COMMAND="echo 'All services ready!'" \
  ogulcanaydogan/wait-for-it
```

## Docker Compose

### As Entrypoint Wrapper

```yaml
version: '3.8'

services:
  app:
    image: myapp
    entrypoint: ["/wait-for-it", "db:5432", "redis:6379", "--"]
    command: ["npm", "start"]
    volumes:
      - ./wait-for-it.sh:/wait-for-it:ro
    depends_on:
      - db
      - redis

  db:
    image: postgres:16

  redis:
    image: redis:7
```

### Using Init Container Pattern

```yaml
version: '3.8'

services:
  wait:
    image: ogulcanaydogan/wait-for-it
    command: ["-t", "60", "db:5432", "redis:6379"]

  app:
    image: myapp
    depends_on:
      wait:
        condition: service_completed_successfully
      db:
        condition: service_started
      redis:
        condition: service_started

  db:
    image: postgres:16

  redis:
    image: redis:7
```

### With Environment Variables

```yaml
version: '3.8'

services:
  app:
    image: myapp
    environment:
      - WAIT_HOSTS=db:5432,redis:6379,api:8080
      - WAIT_TIMEOUT=120
    entrypoint: ["/wait-for-it"]
    command: ["--", "npm", "start"]
```

## Kubernetes

### Init Container

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      initContainers:
      - name: wait-for-db
        image: ogulcanaydogan/wait-for-it
        args:
          - "-t"
          - "60"
          - "postgres-service:5432"
          - "redis-service:6379"

      containers:
      - name: app
        image: myapp
```

### With Multiple Services

```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      initContainers:
      - name: wait-for-services
        image: ogulcanaydogan/wait-for-it
        args:
          - "--parallel"
          - "-t"
          - "120"
          - "postgres:5432"
          - "redis:6379"
          - "elasticsearch:9200"
          - "rabbitmq:5672"

      containers:
      - name: app
        image: myapp
```

## Common Service Ports

| Service | Default Port |
|---------|-------------|
| PostgreSQL | 5432 |
| MySQL | 3306 |
| MongoDB | 27017 |
| Redis | 6379 |
| Elasticsearch | 9200 |
| RabbitMQ | 5672 |
| Kafka | 9092 |
| Memcached | 11211 |
| NATS | 4222 |

## Examples

### Wait for Database Before Migrations

```bash
docker run --rm \
  ogulcanaydogan/wait-for-it \
  -t 60 \
  db:5432 \
  -- \
  npm run migrate
```

### CI/CD Pipeline

```yaml
# GitHub Actions
- name: Wait for services
  run: |
    docker run --rm --network host ogulcanaydogan/wait-for-it \
      -t 60 --parallel \
      localhost:5432 \
      localhost:6379
```

### Shell Script

```bash
#!/bin/bash
set -e

# Copy wait-for-it to your image or use as sidecar
wait-for-it -t 60 db:5432 redis:6379

echo "Starting application..."
exec npm start
```

## Building

```bash
docker build -t ogulcanaydogan/wait-for-it .
```

## License

MIT License
