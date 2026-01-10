#!/usr/bin/env python3
import os
import sys
import time
import json
import gzip
from datetime import datetime
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class LogBuffer:
    def __init__(self, max_size=100):
        self.buffer = []
        self.max_size = max_size

    def add(self, line):
        self.buffer.append(line)
        return len(self.buffer) >= self.max_size

    def flush(self):
        data = self.buffer.copy()
        self.buffer = []
        return data

class S3Exporter:
    def __init__(self, bucket, prefix, region):
        import boto3
        self.client = boto3.client('s3', region_name=region)
        self.bucket = bucket
        self.prefix = prefix

    def export(self, logs):
        if not logs:
            return

        timestamp = datetime.utcnow().strftime('%Y/%m/%d/%H%M%S')
        key = f"{self.prefix}/{timestamp}.json.gz"

        # Compress and upload
        data = json.dumps(logs).encode('utf-8')
        compressed = gzip.compress(data)

        self.client.put_object(
            Bucket=self.bucket,
            Key=key,
            Body=compressed,
            ContentType='application/json',
            ContentEncoding='gzip'
        )
        print(f"[{datetime.now()}] Exported {len(logs)} logs to s3://{self.bucket}/{key}")

class CloudWatchExporter:
    def __init__(self, log_group, log_stream, region):
        import boto3
        self.client = boto3.client('logs', region_name=region)
        self.log_group = log_group
        self.log_stream = log_stream
        self._ensure_log_group()

    def _ensure_log_group(self):
        try:
            self.client.create_log_group(logGroupName=self.log_group)
        except:
            pass
        try:
            self.client.create_log_stream(
                logGroupName=self.log_group,
                logStreamName=self.log_stream
            )
        except:
            pass

    def export(self, logs):
        if not logs:
            return

        events = [
            {'timestamp': int(time.time() * 1000), 'message': log}
            for log in logs
        ]

        self.client.put_log_events(
            logGroupName=self.log_group,
            logStreamName=self.log_stream,
            logEvents=events
        )
        print(f"[{datetime.now()}] Exported {len(logs)} logs to CloudWatch")

class LogHandler(FileSystemEventHandler):
    def __init__(self, buffer, file_positions):
        self.buffer = buffer
        self.file_positions = file_positions

    def on_modified(self, event):
        if event.is_directory:
            return

        filepath = event.src_path
        if not filepath.endswith('.log'):
            return

        pos = self.file_positions.get(filepath, 0)

        with open(filepath, 'r') as f:
            f.seek(pos)
            for line in f:
                line = line.strip()
                if line:
                    self.buffer.add(line)
            self.file_positions[filepath] = f.tell()

def main():
    export_type = os.environ.get('EXPORT_TYPE', 's3')
    log_path = os.environ.get('LOG_PATH', '/logs')
    batch_size = int(os.environ.get('BATCH_SIZE', '100'))
    flush_interval = int(os.environ.get('FLUSH_INTERVAL', '60'))

    if export_type == 's3':
        bucket = os.environ.get('S3_BUCKET')
        if not bucket:
            print("Error: S3_BUCKET is required")
            sys.exit(1)
        exporter = S3Exporter(
            bucket=bucket,
            prefix=os.environ.get('S3_PREFIX', 'logs'),
            region=os.environ.get('AWS_REGION', 'us-east-1')
        )
    elif export_type == 'cloudwatch':
        exporter = CloudWatchExporter(
            log_group=os.environ.get('CW_LOG_GROUP', '/app/logs'),
            log_stream=os.environ.get('CW_LOG_STREAM', 'default'),
            region=os.environ.get('AWS_REGION', 'us-east-1')
        )
    else:
        print(f"Error: Unknown export type '{export_type}'")
        sys.exit(1)

    buffer = LogBuffer(batch_size)
    file_positions = {}

    handler = LogHandler(buffer, file_positions)
    observer = Observer()
    observer.schedule(handler, log_path, recursive=True)
    observer.start()

    print(f"Watching {log_path} for log files...")
    print(f"Export type: {export_type}, Batch size: {batch_size}, Flush interval: {flush_interval}s")

    last_flush = time.time()

    try:
        while True:
            time.sleep(1)

            if time.time() - last_flush >= flush_interval:
                logs = buffer.flush()
                if logs:
                    exporter.export(logs)
                last_flush = time.time()

    except KeyboardInterrupt:
        observer.stop()

    observer.join()

if __name__ == '__main__':
    main()
