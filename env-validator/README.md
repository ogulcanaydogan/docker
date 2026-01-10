# Env Validator

Validate required environment variables before your app starts.

## Quick Start

```bash
docker run -e REQUIRED_VARS="DB_HOST,API_KEY,SECRET" ogulcanaydogan/env-validator
```

## Use in Docker Compose

```yaml
services:
  validator:
    image: ogulcanaydogan/env-validator
    environment:
      - REQUIRED_VARS=DB_HOST,DB_USER,DB_PASSWORD
      - DB_HOST=${DB_HOST}
      - DB_USER=${DB_USER}
      - DB_PASSWORD=${DB_PASSWORD}

  app:
    image: myapp
    depends_on:
      validator:
        condition: service_completed_successfully
```

## Options

| Variable | Description |
|----------|-------------|
| `REQUIRED_VARS` | Comma-separated list of required variables |
| `OPTIONAL_VARS` | Warn if missing but don't fail |
| `STRICT` | Exit code 1 on any warning (default: false) |

## Exit Codes

- `0` - All required variables present
- `1` - Missing required variables

## License

MIT
