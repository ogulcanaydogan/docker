# env-validator

Validate environment variables against a YAML or JSON schema. Ensure your application has all required configuration before startup.

## Features

- YAML and JSON schema support
- Multiple validation types (string, integer, boolean, url, email, port, ip)
- Regex pattern matching
- Enum value validation
- String length validation
- Required/optional fields
- Colored terminal output
- Exit codes for CI/CD integration

## Quick Start

```bash
docker pull ogulcanaydogan/env-validator
```

## Usage

### Basic Validation

```bash
# Validate against schema
docker run --rm \
  -v $(pwd)/env.schema.yaml:/app/env.schema.yaml \
  -e DATABASE_URL=postgres://localhost/db \
  -e NODE_ENV=production \
  ogulcanaydogan/env-validator -s env.schema.yaml
```

### With .env File

```bash
docker run --rm \
  -v $(pwd):/app \
  ogulcanaydogan/env-validator -s env.schema.yaml --env-file .env
```

### Generate Example Schema

```bash
docker run --rm ogulcanaydogan/env-validator --generate-example > env.schema.yaml
```

### Verbose Output

```bash
docker run --rm \
  -v $(pwd):/app \
  --env-file .env \
  ogulcanaydogan/env-validator -s env.schema.yaml --verbose
```

## Schema Format

Create a `env.schema.yaml` file:

```yaml
variables:
  # Simple type validation
  DATABASE_URL:
    type: url
    required: true
    description: Database connection string

  # Enum validation
  NODE_ENV:
    type: string
    required: true
    enum: [development, staging, production]

  # Pattern matching
  API_KEY:
    type: string
    required: true
    pattern: "^sk_[a-zA-Z0-9]{32}$"

  # Length validation
  SECRET_KEY:
    type: string
    required: true
    min_length: 32
    max_length: 64

  # Optional with type
  DEBUG:
    type: boolean
    required: false

  # Port validation
  PORT:
    type: port
    required: false
```

## Supported Types

| Type | Description | Example |
|------|-------------|---------|
| `string` | Any string value | `hello` |
| `integer` | Whole numbers | `42` |
| `float` / `number` | Decimal numbers | `3.14` |
| `boolean` | Boolean values | `true`, `false`, `1`, `0`, `yes`, `no` |
| `url` | Valid URL | `https://example.com` |
| `email` | Email address | `user@example.com` |
| `port` | Port number (1-65535) | `8080` |
| `ip` | IPv4 address | `192.168.1.1` |

## Schema Properties

| Property | Type | Description |
|----------|------|-------------|
| `type` | string | Variable type (see above) |
| `required` | boolean | Whether variable is required (default: `true`) |
| `enum` | array | List of allowed values |
| `pattern` | string | Regex pattern to match |
| `min_length` | integer | Minimum string length |
| `max_length` | integer | Maximum string length |
| `description` | string | Human-readable description |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All validations passed |
| 1 | Validation failed or error |

## CI/CD Integration

### GitHub Actions

```yaml
- name: Validate environment
  run: |
    docker run --rm \
      -v ${{ github.workspace }}:/app \
      -e DATABASE_URL=${{ secrets.DATABASE_URL }} \
      -e NODE_ENV=production \
      ogulcanaydogan/env-validator -s env.schema.yaml
```

### GitLab CI

```yaml
validate-env:
  image: ogulcanaydogan/env-validator
  script:
    - env-validator -s env.schema.yaml
  variables:
    DATABASE_URL: $DATABASE_URL
    NODE_ENV: production
```

### Docker Compose Health Check

```yaml
services:
  app:
    image: myapp
    depends_on:
      env-check:
        condition: service_completed_successfully

  env-check:
    image: ogulcanaydogan/env-validator
    volumes:
      - ./env.schema.yaml:/app/env.schema.yaml
    environment:
      - DATABASE_URL
      - NODE_ENV
    command: ["-s", "env.schema.yaml"]
```

## Kubernetes Init Container

```yaml
apiVersion: v1
kind: Pod
spec:
  initContainers:
  - name: env-validator
    image: ogulcanaydogan/env-validator
    command: ["env-validator", "-s", "/config/env.schema.yaml"]
    envFrom:
    - secretRef:
        name: app-secrets
    - configMapRef:
        name: app-config
    volumeMounts:
    - name: schema
      mountPath: /config
  containers:
  - name: app
    image: myapp
  volumes:
  - name: schema
    configMap:
      name: env-schema
```

## Building

```bash
docker build -t ogulcanaydogan/env-validator .
```

## License

MIT License
