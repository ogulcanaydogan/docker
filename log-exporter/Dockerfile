FROM python:3.12-slim

RUN pip install --no-cache-dir boto3 watchdog

COPY exporter.py /exporter.py
RUN chmod +x /exporter.py

ENV LOG_PATH="/logs"
ENV EXPORT_TYPE="s3"
ENV S3_BUCKET=""
ENV S3_PREFIX="logs"
ENV AWS_REGION="us-east-1"
ENV BATCH_SIZE="100"
ENV FLUSH_INTERVAL="60"

VOLUME ["/logs"]

ENTRYPOINT ["python", "/exporter.py"]
