FROM python:3.12-slim

WORKDIR /app

RUN pip install --no-cache-dir flask gunicorn

COPY app.py .

ENV PORT=5000
ENV WORKERS=2

EXPOSE 5000

CMD gunicorn --bind 0.0.0.0:$PORT --workers $WORKERS app:app
