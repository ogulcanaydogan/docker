# Docker Toolkit

A collection of useful Docker images for development, DevOps, and automation.

## Images

### Utility Tools
| Image | Description | Docker Hub |
|-------|-------------|------------|
| [db-backup](./db-backup) | Universal database backup tool (PostgreSQL, MySQL, MongoDB, Redis) | `ogulcanaydogan/db-backup` |
| [env-validator](./env-validator) | Validate environment variables against a schema | `ogulcanaydogan/env-validator` |
| [ssl-gen](./ssl-gen) | Self-signed SSL certificate generator | `ogulcanaydogan/ssl-gen` |

### Development Environments
| Image | Description | Docker Hub |
|-------|-------------|------------|
| [devbox](./devbox) | All-in-one development container | `ogulcanaydogan/devbox` |
| [db-toolkit](./db-toolkit) | Multi-database development environment | `ogulcanaydogan/db-toolkit` |

### Application Templates
| Image | Description | Docker Hub |
|-------|-------------|------------|
| [fastapi-starter](./fastapi-starter) | Production-ready FastAPI template | `ogulcanaydogan/fastapi-starter` |
| [express-starter](./express-starter) | Node.js/TypeScript API template | `ogulcanaydogan/express-starter` |

### CLI Tools
| Image | Description | Docker Hub |
|-------|-------------|------------|
| [docker-cleanup](./docker-cleanup) | Smart Docker system cleanup | `ogulcanaydogan/docker-cleanup` |
| [healthcheck](./healthcheck) | Universal HTTP/TCP health checker | `ogulcanaydogan/healthcheck` |
| [wait-for-it](./wait-for-it) | Wait for services to be ready | `ogulcanaydogan/wait-for-it` |

## Quick Start

Each image can be pulled from Docker Hub:

```bash
docker pull ogulcanaydogan/<image-name>
```

See individual project READMEs for detailed usage instructions.

## License

MIT License - See [LICENSE](./LICENSE) for details.
