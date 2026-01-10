#!/bin/bash
set -e

if [ -z "$CRON_COMMAND" ]; then
    echo "Error: CRON_COMMAND environment variable is required"
    exit 1
fi

echo "Setting up cron job: $CRON_SCHEDULE"
echo "Command: $CRON_COMMAND"

# Create cron job
echo "$CRON_SCHEDULE $CRON_COMMAND" > /etc/crontabs/root

# Run on startup if requested
if [ "$RUN_ON_STARTUP" = "true" ]; then
    echo "Running command on startup..."
    eval "$CRON_COMMAND"
fi

echo "Starting cron daemon..."
exec crond -f -l 2
