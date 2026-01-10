# Docker Cleanup

Lightweight utility to clean up unused Docker resources (containers, images, volumes, networks).

## Quick Start

```bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ogulcanaydogan/docker-cleanup
```

## What It Cleans

- Stopped containers
- Dangling images
- Unused volumes
- Unused networks

## Options

| Environment Variable | Description | Default |
|---------------------|-------------|---------|
| `CLEAN_IMAGES` | Remove dangling images | `true` |
| `CLEAN_VOLUMES` | Remove unused volumes | `true` |
| `CLEAN_NETWORKS` | Remove unused networks | `true` |
| `DRY_RUN` | Preview without deleting | `false` |

## Example

```bash
# Dry run - see what would be deleted
docker run --rm -e DRY_RUN=true -v /var/run/docker.sock:/var/run/docker.sock ogulcanaydogan/docker-cleanup

# Clean everything except volumes
docker run --rm -e CLEAN_VOLUMES=false -v /var/run/docker.sock:/var/run/docker.sock ogulcanaydogan/docker-cleanup
```

## License

MIT