#!/bin/bash
set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                     DevBox Development Environment            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Available tools:"
echo "  Languages:  Python $(python3 --version 2>&1 | cut -d' ' -f2), Node.js $(node --version), Go $(go version | cut -d' ' -f3)"
echo "  DevOps:     Docker, kubectl, Helm, Terraform, AWS CLI"
echo "  Utilities:  git, vim, neovim, tmux, fzf, ripgrep, jq, yq"
echo ""
echo "Workspace: /workspace"
echo ""

# If GIT_USER_NAME and GIT_USER_EMAIL are set, configure git
if [ -n "$GIT_USER_NAME" ]; then
    git config --global user.name "$GIT_USER_NAME"
fi

if [ -n "$GIT_USER_EMAIL" ]; then
    git config --global user.email "$GIT_USER_EMAIL"
fi

# Execute the command passed to the container
exec "$@"
