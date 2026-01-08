# ssl-gen

Self-signed SSL certificate generator for local development. Creates a complete CA and server certificate chain.

## Features

- Generates CA certificate and server certificate
- Subject Alternative Names (SAN) support
- Wildcard certificate support
- Multiple output formats (PEM, CRT, P12)
- Full chain certificate bundle
- Easy browser/system trust setup

## Quick Start

```bash
docker pull ogulcanaydogan/ssl-gen
```

## Usage

### Basic (localhost)

```bash
docker run --rm -v $(pwd)/certs:/certs ogulcanaydogan/ssl-gen
```

### Custom Domain

```bash
docker run --rm \
  -v $(pwd)/certs:/certs \
  -e DOMAIN=myapp.local \
  ogulcanaydogan/ssl-gen
```

### Multiple Domains (SAN)

```bash
docker run --rm \
  -v $(pwd)/certs:/certs \
  -e DOMAIN=myapp.local \
  -e ALT_NAMES="api.myapp.local,admin.myapp.local,192.168.1.100" \
  ogulcanaydogan/ssl-gen
```

### Custom Validity Period

```bash
docker run --rm \
  -v $(pwd)/certs:/certs \
  -e DOMAIN=myapp.local \
  -e DAYS=730 \
  ogulcanaydogan/ssl-gen
```

### Full Customization

```bash
docker run --rm \
  -v $(pwd)/certs:/certs \
  -e DOMAIN=api.example.com \
  -e ALT_NAMES="www.example.com,admin.example.com" \
  -e DAYS=365 \
  -e KEY_SIZE=4096 \
  -e CERT_NAME=api \
  -e COUNTRY=US \
  -e STATE=California \
  -e CITY="San Francisco" \
  -e ORG="My Company" \
  -e EMAIL=admin@example.com \
  -e P12_PASSWORD=mysecret \
  ogulcanaydogan/ssl-gen
```

## Generated Files

| File | Description |
|------|-------------|
| `ca.crt` | CA certificate (install in browser/system) |
| `ca.key` | CA private key (keep secure!) |
| `server.crt` | Server certificate |
| `server.key` | Server private key |
| `server.pem` | Combined certificate + key |
| `server.fullchain.crt` | Full chain (server cert + CA) |
| `server.p12` | PKCS12 bundle for Java/Windows |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DOMAIN` | `localhost` | Primary domain name |
| `ALT_NAMES` | - | Comma-separated additional domains/IPs |
| `DAYS` | `365` | Certificate validity in days |
| `KEY_SIZE` | `2048` | RSA key size (2048 or 4096) |
| `OUTPUT_DIR` | `/certs` | Output directory |
| `CERT_NAME` | `server` | Certificate filename prefix |
| `COUNTRY` | `US` | Country code |
| `STATE` | `California` | State/Province |
| `CITY` | `San Francisco` | City |
| `ORG` | `Development` | Organization name |
| `ORG_UNIT` | `IT` | Organizational unit |
| `EMAIL` | `admin@localhost` | Contact email |
| `P12_PASSWORD` | `changeit` | PKCS12 bundle password |

## Trust the CA Certificate

### macOS

```bash
sudo security add-trusted-cert -d -r trustRoot \
  -k /Library/Keychains/System.keychain ./certs/ca.crt
```

### Linux (Ubuntu/Debian)

```bash
sudo cp ./certs/ca.crt /usr/local/share/ca-certificates/myca.crt
sudo update-ca-certificates
```

### Linux (RHEL/CentOS)

```bash
sudo cp ./certs/ca.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust
```

### Windows

```powershell
Import-Certificate -FilePath .\certs\ca.crt -CertStoreLocation Cert:\LocalMachine\Root
```

### Firefox

Firefox uses its own certificate store:
1. Settings → Privacy & Security → Certificates → View Certificates
2. Authorities → Import → Select `ca.crt`
3. Check "Trust this CA to identify websites"

## Usage Examples

### Nginx

```nginx
server {
    listen 443 ssl;
    server_name myapp.local;

    ssl_certificate /certs/server.fullchain.crt;
    ssl_certificate_key /certs/server.key;
}
```

### Node.js

```javascript
const https = require('https');
const fs = require('fs');

const options = {
  key: fs.readFileSync('./certs/server.key'),
  cert: fs.readFileSync('./certs/server.fullchain.crt')
};

https.createServer(options, (req, res) => {
  res.writeHead(200);
  res.end('Hello HTTPS!');
}).listen(443);
```

### Docker Compose with Nginx

```yaml
version: '3.8'

services:
  ssl-gen:
    image: ogulcanaydogan/ssl-gen
    environment:
      - DOMAIN=myapp.local
    volumes:
      - certs:/certs

  nginx:
    image: nginx:alpine
    ports:
      - "443:443"
    volumes:
      - certs:/certs:ro
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - ssl-gen

volumes:
  certs:
```

### Traefik

```yaml
version: '3.8'

services:
  ssl-gen:
    image: ogulcanaydogan/ssl-gen
    environment:
      - DOMAIN=myapp.local
    volumes:
      - certs:/certs

  traefik:
    image: traefik:v2.10
    command:
      - "--providers.file.filename=/certs/traefik.yml"
    ports:
      - "443:443"
    volumes:
      - certs:/certs:ro

volumes:
  certs:
```

## Building

```bash
docker build -t ogulcanaydogan/ssl-gen .
```

## License

MIT License
