FROM python:3.12-alpine

LABEL maintainer="Ogulcan Aydogan"
LABEL description="Environment variable validator against YAML/JSON schema"

# Install dependencies
RUN pip install --no-cache-dir pyyaml

# Copy validator script
COPY validate.py /usr/local/bin/env-validator
RUN chmod +x /usr/local/bin/env-validator

WORKDIR /app

ENTRYPOINT ["env-validator"]
CMD ["--help"]
