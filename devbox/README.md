# devbox

All-in-one development container with Python, Node.js, Go, Rust, and essential DevOps tools.

## Features

- **Languages**: Python 3.12, Node.js 20 LTS, Go 1.22, Rust
- **Package Managers**: pip, poetry, npm, yarn, pnpm, cargo
- **DevOps Tools**: Docker CLI, kubectl, Helm, Terraform, AWS CLI
- **Editors**: vim, neovim, nano
- **Shell**: zsh with Oh My Zsh, tmux
- **Utilities**: git, fzf, ripgrep, jq, yq, httpie, and more

## Quick Start

```bash
docker pull ogulcanaydogan/devbox
```

## Usage

### Interactive Shell

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  ogulcanaydogan/devbox
```

### With Git Configuration

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GIT_USER_NAME="Your Name" \
  -e GIT_USER_EMAIL="your@email.com" \
  ogulcanaydogan/devbox
```

### With Docker Access (Docker-in-Docker)

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ogulcanaydogan/devbox
```

### With AWS Credentials

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.aws:/root/.aws:ro \
  ogulcanaydogan/devbox
```

### With Kubernetes Config

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.kube:/root/.kube:ro \
  ogulcanaydogan/devbox
```

### Run a Specific Command

```bash
# Run Python script
docker run --rm -v $(pwd):/workspace ogulcanaydogan/devbox python script.py

# Run Node.js app
docker run --rm -v $(pwd):/workspace ogulcanaydogan/devbox node app.js

# Run Go program
docker run --rm -v $(pwd):/workspace ogulcanaydogan/devbox go run main.go

# Run tests
docker run --rm -v $(pwd):/workspace ogulcanaydogan/devbox pytest
```

## Included Tools

### Languages & Runtimes

| Tool | Version | Description |
|------|---------|-------------|
| Python | 3.12 | With pip, poetry, pipenv |
| Node.js | 20 LTS | With npm, yarn, pnpm |
| Go | 1.22 | With common tools |
| Rust | Latest | With cargo |

### Package Managers & Build Tools

- `pip`, `poetry`, `pipenv` - Python
- `npm`, `yarn`, `pnpm` - Node.js
- `go mod` - Go
- `cargo` - Rust
- `make`, `cmake` - Build tools

### DevOps & Cloud

| Tool | Description |
|------|-------------|
| Docker CLI | Container management |
| kubectl | Kubernetes CLI |
| Helm | Kubernetes package manager |
| Terraform | Infrastructure as code |
| AWS CLI | Amazon Web Services |
| GitHub CLI | GitHub operations |

### Code Quality

| Tool | Language | Description |
|------|----------|-------------|
| black | Python | Code formatter |
| flake8 | Python | Linter |
| mypy | Python | Type checker |
| pytest | Python | Test framework |
| eslint | JS/TS | Linter |
| prettier | JS/TS | Formatter |
| biome | JS/TS | Fast linter/formatter |
| golangci-lint | Go | Linter |

### Shell & Utilities

- `zsh` with Oh My Zsh
- `tmux` - Terminal multiplexer
- `fzf` - Fuzzy finder
- `ripgrep` (rg) - Fast grep
- `fd` - Fast find
- `bat` - Better cat
- `jq`, `yq` - JSON/YAML processors
- `httpie` - HTTP client

## VS Code Dev Containers

Create `.devcontainer/devcontainer.json`:

```json
{
  "name": "DevBox",
  "image": "ogulcanaydogan/devbox",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "golang.go",
        "rust-lang.rust-analyzer",
        "dbaeumer.vscode-eslint"
      ]
    }
  },
  "mounts": [
    "source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind"
  ],
  "remoteUser": "root"
}
```

## Docker Compose

```yaml
version: '3.8'

services:
  devbox:
    image: ogulcanaydogan/devbox
    stdin_open: true
    tty: true
    volumes:
      - .:/workspace
      - /var/run/docker.sock:/var/run/docker.sock
      - ~/.aws:/root/.aws:ro
      - ~/.kube:/root/.kube:ro
    environment:
      - GIT_USER_NAME=Your Name
      - GIT_USER_EMAIL=your@email.com
```

## Building

```bash
docker build -t ogulcanaydogan/devbox .
```

## License

MIT License
