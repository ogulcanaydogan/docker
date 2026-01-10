FROM alpine:3.19

RUN apk add --no-cache bash curl wget

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV CRON_SCHEDULE="* * * * *"
ENV CRON_COMMAND=""
ENV RUN_ON_STARTUP="false"

ENTRYPOINT ["/entrypoint.sh"]
