FROM alpine:3.19

RUN apk add --no-cache git openssh-client bash

COPY sync.sh /sync.sh
RUN chmod +x /sync.sh

ENV GIT_REPO=""
ENV GIT_BRANCH="main"
ENV SYNC_INTERVAL="60"
ENV DEST_DIR="/data"

VOLUME ["/data", "/root/.ssh"]

ENTRYPOINT ["/sync.sh"]
