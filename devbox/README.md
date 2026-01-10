# DevBox

All-in-one development environment with common tools pre-installed.

## Quick Start

```bash
docker run -it ogulcanaydogan/devbox
```

## Included Tools

- **Languages**: Python 3, Node.js, Go
- **Version Control**: Git, GitHub CLI
- **Editors**: Vim, Nano
- **Utilities**: curl, wget, jq, htop
- **Cloud CLI**: AWS CLI, Terraform

## Mount Your Code

```bash
docker run -it -v $(pwd):/workspace ogulcanaydogan/devbox
```

## Persist Home Directory

```bash
docker run -it -v devbox-home:/root ogulcanaydogan/devbox
```

## Custom Dotfiles

```bash
docker run -it -v ~/.gitconfig:/root/.gitconfig ogulcanaydogan/devbox
```

## License

MIT
