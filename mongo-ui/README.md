# MongoDB UI

Simple web UI for browsing and managing MongoDB data.

## Quick Start

```bash
docker run -d \
  -e MONGO_URI=mongodb://localhost:27017 \
  -p 8080:8080 \
  ogulcanaydogan/mongo-ui
```

Open http://localhost:8080

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `MONGO_URI` | MongoDB connection URI | `mongodb://mongo:27017` |
| `PORT` | Web UI port | `8080` |

## Features

- Browse databases and collections
- View documents with pagination
- Query documents using MongoDB syntax
- Insert new documents
- Delete documents
- Server stats

## Docker Compose Example

```yaml
services:
  mongo:
    image: mongo:7

  mongo-ui:
    image: ogulcanaydogan/mongo-ui
    environment:
      - MONGO_URI=mongodb://mongo:27017
    ports:
      - "8080:8080"
    depends_on:
      - mongo
```

## Connection with Authentication

```bash
docker run -d \
  -e MONGO_URI="mongodb://user:password@mongo:27017/mydb?authSource=admin" \
  -p 8080:8080 \
  ogulcanaydogan/mongo-ui
```

## API Endpoints

- `GET /api/databases` - List databases
- `GET /api/database/:db/collections` - List collections
- `GET /api/database/:db/collection/:coll` - List documents
- `GET /api/database/:db/collection/:coll/:id` - Get document
- `POST /api/database/:db/collection/:coll` - Insert document
- `DELETE /api/database/:db/collection/:coll/:id` - Delete document
- `GET /health` - Health check

## License

MIT
