# Volume Permissions

Init container to fix Docker volume permissions before your app starts.

## Quick Start

```bash
docker run --rm \
  -e TARGET_UID=1000 \
  -e TARGET_GID=1000 \
  -v myvolume:/data \
  ogulcanaydogan/volume-permissions
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `TARGET_PATH` | Path to fix | `/data` |
| `TARGET_UID` | Owner user ID | `1000` |
| `TARGET_GID` | Owner group ID | `1000` |
| `TARGET_MODE` | Permission mode | `755` |
| `RECURSIVE` | Apply recursively | `true` |

## Common Use Cases

### Fix permissions for non-root container

```bash
docker run --rm \
  -e TARGET_UID=1000 \
  -e TARGET_GID=1000 \
  -v app-data:/data \
  ogulcanaydogan/volume-permissions
```

### Match host user

```bash
docker run --rm \
  -e TARGET_UID=$(id -u) \
  -e TARGET_GID=$(id -g) \
  -v ./data:/data \
  ogulcanaydogan/volume-permissions
```

### Set specific mode

```bash
docker run --rm \
  -e TARGET_MODE=777 \
  -v shared-data:/data \
  ogulcanaydogan/volume-permissions
```

## Docker Compose Example

```yaml
services:
  init-permissions:
    image: ogulcanaydogan/volume-permissions
    environment:
      - TARGET_UID=1000
      - TARGET_GID=1000
    volumes:
      - app-data:/data

  app:
    image: myapp
    user: "1000:1000"
    volumes:
      - app-data:/data
    depends_on:
      init-permissions:
        condition: service_completed_successfully

volumes:
  app-data:
```

## Multiple Volumes

```yaml
services:
  init:
    image: ogulcanaydogan/volume-permissions
    environment:
      - TARGET_PATH=/data
      - TARGET_UID=1000
    volumes:
      - uploads:/data/uploads
      - cache:/data/cache
      - logs:/data/logs
```

## Why This Is Needed

Docker volumes created by root-running containers often have root ownership. When running containers as non-root users (security best practice), these volumes become inaccessible. This init container fixes the permissions before your app starts.

## License

MIT
