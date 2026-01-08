# docker-cleanup

Smart Docker system cleanup tool. Safely remove unused containers, images, volumes, networks, and build cache.

## Features

- Clean stopped containers
- Remove dangling and unused images
- Clean dangling volumes
- Remove unused networks
- Clear build cache
- Dry-run mode to preview changes
- Configurable retention period
- Interactive confirmation prompts

## Quick Start

```bash
docker pull ogulcanaydogan/docker-cleanup
```

## Usage

### Preview Cleanup (Dry Run)

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ogulcanaydogan/docker-cleanup --dry-run
```

### Clean Everything

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ogulcanaydogan/docker-cleanup --all --force
```

### Clean Specific Resources

```bash
# Clean only images
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ogulcanaydogan/docker-cleanup --images --force

# Clean containers and volumes
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ogulcanaydogan/docker-cleanup --containers --volumes --force
```

### Keep Recent Images

```bash
# Keep images used in last 48 hours
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ogulcanaydogan/docker-cleanup --all --force --keep-hours 48
```

## Options

| Option | Short | Description |
|--------|-------|-------------|
| `--all` | `-a` | Clean all resources (default) |
| `--images` | `-i` | Clean dangling and unused images |
| `--containers` | `-c` | Clean stopped containers |
| `--volumes` | `-v` | Clean dangling volumes |
| `--networks` | `-n` | Clean unused networks |
| `--build-cache` | `-b` | Clean build cache |
| `--dry-run` | `-d` | Preview what would be deleted |
| `--force` | `-f` | Skip confirmation prompts |
| `--keep-hours N` | `-k N` | Keep images used in last N hours (default: 24) |
| `--verbose` | | Show detailed output |
| `--help` | `-h` | Show help message |

## What Gets Cleaned

### Containers
- Exited containers
- Dead containers
- Created but never started containers

### Images
- Dangling images (untagged `<none>:<none>`)
- Unused images not referenced by any container
- Respects `--keep-hours` for recently used images

### Volumes
- Dangling volumes not attached to any container

### Networks
- Custom networks not used by any container
- Preserves default networks (bridge, host, none)

### Build Cache
- Intermediate build layers
- Respects `--keep-hours` for recent cache

## Shell Alias

Add to your `.bashrc` or `.zshrc`:

```bash
alias docker-cleanup='docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ogulcanaydogan/docker-cleanup'
```

Then use:

```bash
docker-cleanup --dry-run
docker-cleanup --all --force
```

## Cron Job

Clean Docker resources daily:

```bash
# Edit crontab
crontab -e

# Add daily cleanup at 3 AM
0 3 * * * docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ogulcanaydogan/docker-cleanup --all --force --keep-hours 48 >> /var/log/docker-cleanup.log 2>&1
```

## Systemd Timer

Create `/etc/systemd/system/docker-cleanup.service`:

```ini
[Unit]
Description=Docker Cleanup
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
ExecStart=/usr/bin/docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ogulcanaydogan/docker-cleanup --all --force --keep-hours 48
```

Create `/etc/systemd/system/docker-cleanup.timer`:

```ini
[Unit]
Description=Run Docker Cleanup daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

Enable:

```bash
sudo systemctl enable docker-cleanup.timer
sudo systemctl start docker-cleanup.timer
```

## Kubernetes CronJob

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: docker-cleanup
spec:
  schedule: "0 3 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cleanup
            image: ogulcanaydogan/docker-cleanup
            args: ["--all", "--force", "--keep-hours", "48"]
            volumeMounts:
            - name: docker-sock
              mountPath: /var/run/docker.sock
          volumes:
          - name: docker-sock
            hostPath:
              path: /var/run/docker.sock
          restartPolicy: OnFailure
```

## Safety Features

1. **Dry Run Mode**: Preview all changes before applying
2. **Confirmation Prompts**: Interactive confirmation unless `--force` is used
3. **Retention Period**: Keep recently used images with `--keep-hours`
4. **Selective Cleanup**: Clean only specific resource types
5. **Protected Resources**: Never removes running containers or in-use volumes

## Building

```bash
docker build -t ogulcanaydogan/docker-cleanup .
```

## License

MIT License
