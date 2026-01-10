#!/bin/bash
set -e

if [ -z "$GIT_REPO" ]; then
    echo "Error: GIT_REPO environment variable is required"
    exit 1
fi

# Configure git
git config --global --add safe.directory "$DEST_DIR"

# Initial clone or pull
if [ ! -d "$DEST_DIR/.git" ]; then
    echo "Cloning $GIT_REPO (branch: $GIT_BRANCH) to $DEST_DIR"
    git clone --branch "$GIT_BRANCH" --single-branch "$GIT_REPO" "$DEST_DIR"
else
    echo "Repository already exists, pulling latest"
    cd "$DEST_DIR"
    git fetch origin
    git reset --hard "origin/$GIT_BRANCH"
fi

echo "Starting sync loop (interval: ${SYNC_INTERVAL}s)"

while true; do
    sleep "$SYNC_INTERVAL"
    echo "[$(date)] Syncing..."
    cd "$DEST_DIR"
    git fetch origin
    git reset --hard "origin/$GIT_BRANCH"
    echo "[$(date)] Sync complete"
done
