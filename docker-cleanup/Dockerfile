FROM docker:24-cli

LABEL maintainer="Ogulcan Aydogan"
LABEL description="Smart Docker system cleanup tool"

# Install bash
RUN apk add --no-cache bash

# Copy cleanup script
COPY cleanup.sh /usr/local/bin/docker-cleanup
RUN chmod +x /usr/local/bin/docker-cleanup

ENTRYPOINT ["/usr/local/bin/docker-cleanup"]
CMD ["--help"]
