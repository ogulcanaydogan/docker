FROM python:3.12-slim

RUN pip install --no-cache-dir flask pymongo

COPY app.py /app.py
COPY templates /templates

ENV MONGO_URI="mongodb://mongo:27017"
ENV MONGO_DB=""
ENV PORT="8080"

EXPOSE 8080

CMD ["python", "/app.py"]
