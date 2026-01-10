# Git Sync

Continuously sync a git repository to a local directory.

## Quick Start

```bash
docker run -d \
  -e GIT_REPO=https://github.com/user/repo.git \
  -v $(pwd)/data:/data \
  ogulcanaydogan/git-sync
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `GIT_REPO` | Repository URL (required) | - |
| `GIT_BRANCH` | Branch to sync | `main` |
| `SYNC_INTERVAL` | Sync interval in seconds | `60` |
| `DEST_DIR` | Destination directory | `/data` |

## Private Repositories

Mount your SSH key:

```bash
docker run -d \
  -e GIT_REPO=git@github.com:user/private-repo.git \
  -v ~/.ssh:/root/.ssh:ro \
  -v $(pwd)/data:/data \
  ogulcanaydogan/git-sync
```

## Docker Compose Example

```yaml
services:
  config:
    image: ogulcanaydogan/git-sync
    environment:
      - GIT_REPO=https://github.com/user/config.git
      - SYNC_INTERVAL=300
    volumes:
      - config-data:/data

  app:
    image: myapp
    volumes:
      - config-data:/config:ro

volumes:
  config-data:
```

## License

MIT
