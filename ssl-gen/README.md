# SSL Gen

Generate self-signed SSL certificates for development.

## Quick Start

```bash
docker run -v $(pwd)/certs:/certs ogulcanaydogan/ssl-gen
```

Creates `server.crt` and `server.key` in the mounted directory.

## Custom Domain

```bash
docker run -v $(pwd)/certs:/certs -e DOMAIN=myapp.local ogulcanaydogan/ssl-gen
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DOMAIN` | Certificate domain | `localhost` |
| `DAYS` | Validity in days | `365` |
| `KEY_SIZE` | RSA key size | `2048` |
| `COUNTRY` | Country code | `US` |
| `ORG` | Organization name | `Dev` |

## Use with Nginx

```yaml
services:
  ssl:
    image: ogulcanaydogan/ssl-gen
    volumes:
      - certs:/certs
    environment:
      - DOMAIN=myapp.local

  nginx:
    image: nginx
    volumes:
      - certs:/etc/nginx/certs:ro
    depends_on:
      - ssl
```

## License

MIT
