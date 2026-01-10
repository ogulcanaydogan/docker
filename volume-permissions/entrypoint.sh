#!/bin/sh
set -e

echo "Volume Permissions Fixer"
echo "========================"
echo "Target path: $TARGET_PATH"
echo "UID: $TARGET_UID"
echo "GID: $TARGET_GID"
echo "Mode: $TARGET_MODE"
echo "Recursive: $RECURSIVE"
echo ""

if [ ! -d "$TARGET_PATH" ]; then
    echo "Creating directory: $TARGET_PATH"
    mkdir -p "$TARGET_PATH"
fi

echo "Setting ownership..."
if [ "$RECURSIVE" = "true" ]; then
    chown -R "$TARGET_UID:$TARGET_GID" "$TARGET_PATH"
else
    chown "$TARGET_UID:$TARGET_GID" "$TARGET_PATH"
fi

echo "Setting permissions..."
if [ "$RECURSIVE" = "true" ]; then
    chmod -R "$TARGET_MODE" "$TARGET_PATH"
else
    chmod "$TARGET_MODE" "$TARGET_PATH"
fi

echo ""
echo "Done! Current permissions:"
ls -la "$TARGET_PATH"

# If a command was passed, execute it
if [ $# -gt 0 ]; then
    echo ""
    echo "Executing: $@"
    exec "$@"
fi
