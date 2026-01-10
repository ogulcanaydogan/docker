FROM python:3.12-slim

RUN pip install --no-cache-dir flask redis

COPY app.py /app.py
COPY templates /templates

ENV REDIS_HOST="redis"
ENV REDIS_PORT="6379"
ENV REDIS_PASSWORD=""
ENV PORT="8080"

EXPOSE 8080

CMD ["python", "/app.py"]
