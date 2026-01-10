# Secrets Init

Fetch secrets from AWS Secrets Manager or HashiCorp Vault and write them to a file.

## Quick Start (AWS)

```bash
docker run \
  -e SECRET_NAME=myapp/production \
  -e AWS_ACCESS_KEY_ID=xxx \
  -e AWS_SECRET_ACCESS_KEY=xxx \
  -v $(pwd)/secrets:/secrets \
  ogulcanaydogan/secrets-init
```

## Quick Start (Vault)

```bash
docker run \
  -e SECRETS_PROVIDER=vault \
  -e VAULT_ADDR=http://vault:8200 \
  -e VAULT_TOKEN=xxx \
  -e VAULT_SECRET_PATH=secret/myapp \
  -v $(pwd)/secrets:/secrets \
  ogulcanaydogan/secrets-init
```

## Environment Variables

### AWS Secrets Manager

| Variable | Description | Default |
|----------|-------------|---------|
| `SECRETS_PROVIDER` | Provider type | `aws` |
| `SECRET_NAME` | Secret name/ARN (required) | - |
| `AWS_REGION` | AWS region | `us-east-1` |
| `AWS_ACCESS_KEY_ID` | AWS access key | - |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | - |
| `OUTPUT_FILE` | Output file path | `/secrets/.env` |

### HashiCorp Vault

| Variable | Description | Default |
|----------|-------------|---------|
| `SECRETS_PROVIDER` | Set to `vault` | `aws` |
| `VAULT_ADDR` | Vault server URL (required) | - |
| `VAULT_TOKEN` | Vault token (required) | - |
| `VAULT_SECRET_PATH` | Secret path (required) | - |
| `OUTPUT_FILE` | Output file path | `/secrets/.env` |

## Docker Compose Example

```yaml
services:
  secrets:
    image: ogulcanaydogan/secrets-init
    environment:
      - SECRET_NAME=myapp/production
      - AWS_REGION=us-east-1
    volumes:
      - secrets:/secrets

  app:
    image: myapp
    depends_on:
      secrets:
        condition: service_completed_successfully
    volumes:
      - secrets:/secrets:ro
    env_file:
      - /secrets/.env

volumes:
  secrets:
```

## License

MIT
