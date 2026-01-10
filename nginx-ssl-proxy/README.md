# Nginx SSL Proxy

Reverse proxy with automatic SSL (Let's Encrypt or self-signed).

## Quick Start (Self-Signed)

```bash
docker run -d \
  -e UPSTREAM_HOST=myapp \
  -e UPSTREAM_PORT=3000 \
  -p 80:80 -p 443:443 \
  ogulcanaydogan/nginx-ssl-proxy
```

## Quick Start (Let's Encrypt)

```bash
docker run -d \
  -e UPSTREAM_HOST=myapp \
  -e UPSTREAM_PORT=3000 \
  -e SERVER_NAME=example.com \
  -e AUTO_SSL=true \
  -e SSL_EMAIL=admin@example.com \
  -p 80:80 -p 443:443 \
  ogulcanaydogan/nginx-ssl-proxy
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `UPSTREAM_HOST` | Backend host | `app` |
| `UPSTREAM_PORT` | Backend port | `3000` |
| `SERVER_NAME` | Domain name | `localhost` |
| `AUTO_SSL` | Use Let's Encrypt | `false` |
| `SSL_EMAIL` | Email for Let's Encrypt | - |

## Features

- Automatic HTTP → HTTPS redirect
- WebSocket support
- Let's Encrypt auto-renewal
- Self-signed fallback for development

## Docker Compose Example

```yaml
services:
  proxy:
    image: ogulcanaydogan/nginx-ssl-proxy
    environment:
      - UPSTREAM_HOST=app
      - UPSTREAM_PORT=3000
      - SERVER_NAME=example.com
      - AUTO_SSL=true
      - SSL_EMAIL=admin@example.com
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - certs:/etc/letsencrypt

  app:
    image: myapp
    expose:
      - "3000"

volumes:
  certs:
```

## License

MIT
