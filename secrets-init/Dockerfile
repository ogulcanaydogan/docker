FROM python:3.12-slim

RUN pip install --no-cache-dir boto3 hvac

COPY secrets-init.py /secrets-init.py
RUN chmod +x /secrets-init.py

ENV SECRETS_PROVIDER="aws"
ENV AWS_REGION="us-east-1"
ENV SECRET_NAME=""
ENV OUTPUT_FILE="/secrets/.env"

VOLUME ["/secrets"]

ENTRYPOINT ["python", "/secrets-init.py"]
