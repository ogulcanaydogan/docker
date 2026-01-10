# SMTP Relay

Simple SMTP relay for sending emails from containers via external SMTP providers.

## Quick Start

```bash
docker run -d \
  -e RELAY_HOST=smtp.gmail.com \
  -e RELAY_USER=your@gmail.com \
  -e RELAY_PASSWORD=your-app-password \
  -p 25:25 \
  ogulcanaydogan/smtp-relay
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `RELAY_HOST` | SMTP relay host (required) | - |
| `RELAY_PORT` | SMTP relay port | `587` |
| `RELAY_USER` | SMTP username | - |
| `RELAY_PASSWORD` | SMTP password | - |
| `ALLOWED_NETWORKS` | Networks allowed to relay | `10.0.0.0/8 172.16.0.0/12 192.168.0.0/16` |

## Supported Providers

| Provider | RELAY_HOST | RELAY_PORT |
|----------|------------|------------|
| Gmail | smtp.gmail.com | 587 |
| SendGrid | smtp.sendgrid.net | 587 |
| Mailgun | smtp.mailgun.org | 587 |
| AWS SES | email-smtp.us-east-1.amazonaws.com | 587 |

## Docker Compose Example

```yaml
services:
  smtp:
    image: ogulcanaydogan/smtp-relay
    environment:
      - RELAY_HOST=smtp.sendgrid.net
      - RELAY_USER=apikey
      - RELAY_PASSWORD=${SENDGRID_API_KEY}
    ports:
      - "25:25"

  app:
    image: myapp
    environment:
      - SMTP_HOST=smtp
      - SMTP_PORT=25
```

## Usage from Applications

Configure your app to use `smtp` (container name) as the SMTP host on port 25. No authentication needed from internal containers.

```python
# Python example
import smtplib
smtp = smtplib.SMTP('smtp', 25)
smtp.sendmail('from@example.com', 'to@example.com', message)
```

## License

MIT
