FROM alpine:3.19

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV TARGET_PATH="/data"
ENV TARGET_UID="1000"
ENV TARGET_GID="1000"
ENV TARGET_MODE="755"
ENV RECURSIVE="true"

VOLUME ["/data"]

ENTRYPOINT ["/entrypoint.sh"]
