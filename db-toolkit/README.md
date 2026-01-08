# db-toolkit

Multi-database development environment with PostgreSQL, MySQL, MongoDB, Redis, and web-based management UIs.

## Features

- **PostgreSQL 16** - Relational database
- **MySQL 8.0** - Relational database
- **MongoDB 7** - Document database
- **Redis 7** - In-memory data store
- **Adminer** - Web UI for PostgreSQL/MySQL
- **Mongo Express** - Web UI for MongoDB
- **Redis Commander** - Web UI for Redis

## Quick Start

```bash
# Clone or download the db-toolkit directory
cd db-toolkit

# Copy environment file
cp .env.example .env

# Start all services
docker compose up -d

# Check status
docker compose ps
```

## Access Points

| Service | URL/Port | Default Credentials |
|---------|----------|---------------------|
| PostgreSQL | `localhost:5432` | `postgres` / `postgres` |
| MySQL | `localhost:3306` | `root` / `mysql` or `mysql` / `mysql` |
| MongoDB | `localhost:27017` | `mongo` / `mongo` |
| Redis | `localhost:6379` | password: `redis` |
| Adminer | http://localhost:8080 | Use DB credentials |
| Mongo Express | http://localhost:8081 | `admin` / `admin` |
| Redis Commander | http://localhost:8082 | No auth required |

## Usage

### Start All Services

```bash
docker compose up -d
```

### Start Specific Services

```bash
# Only PostgreSQL
docker compose up -d postgres

# PostgreSQL with Adminer
docker compose up -d postgres adminer

# Only Redis
docker compose up -d redis redis-commander
```

### Stop Services

```bash
# Stop all
docker compose down

# Stop and remove volumes (delete all data)
docker compose down -v
```

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f postgres
```

## Connection Examples

### PostgreSQL

```bash
# CLI
docker compose exec postgres psql -U postgres -d devdb

# Connection string
postgresql://postgres:postgres@localhost:5432/devdb
```

### MySQL

```bash
# CLI
docker compose exec mysql mysql -u mysql -pmysql devdb

# Connection string
mysql://mysql:mysql@localhost:3306/devdb
```

### MongoDB

```bash
# CLI
docker compose exec mongodb mongosh -u mongo -p mongo

# Connection string
mongodb://mongo:mongo@localhost:27017/devdb?authSource=admin
```

### Redis

```bash
# CLI
docker compose exec redis redis-cli -a redis

# Connection string
redis://:redis@localhost:6379/0
```

## Configuration

Copy `.env.example` to `.env` and customize:

```bash
cp .env.example .env
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_USER` | `postgres` | PostgreSQL username |
| `POSTGRES_PASSWORD` | `postgres` | PostgreSQL password |
| `POSTGRES_DB` | `devdb` | PostgreSQL database |
| `POSTGRES_PORT` | `5432` | PostgreSQL port |
| `MYSQL_ROOT_PASSWORD` | `mysql` | MySQL root password |
| `MYSQL_USER` | `mysql` | MySQL username |
| `MYSQL_PASSWORD` | `mysql` | MySQL password |
| `MYSQL_DB` | `devdb` | MySQL database |
| `MYSQL_PORT` | `3306` | MySQL port |
| `MONGO_USER` | `mongo` | MongoDB username |
| `MONGO_PASSWORD` | `mongo` | MongoDB password |
| `MONGO_DB` | `devdb` | MongoDB database |
| `MONGO_PORT` | `27017` | MongoDB port |
| `REDIS_PASSWORD` | `redis` | Redis password |
| `REDIS_PORT` | `6379` | Redis port |

## Data Persistence

All databases use named Docker volumes for data persistence:

- `postgres_data` - PostgreSQL data
- `mysql_data` - MySQL data
- `mongodb_data` - MongoDB data
- `redis_data` - Redis data

To reset all data:

```bash
docker compose down -v
```

## Integration with Applications

### Node.js Example

```javascript
// PostgreSQL
const { Pool } = require('pg');
const pgPool = new Pool({
  connectionString: 'postgresql://postgres:postgres@localhost:5432/devdb'
});

// MySQL
const mysql = require('mysql2/promise');
const mysqlConn = await mysql.createConnection({
  uri: 'mysql://mysql:mysql@localhost:3306/devdb'
});

// MongoDB
const { MongoClient } = require('mongodb');
const mongoClient = new MongoClient('mongodb://mongo:mongo@localhost:27017/devdb?authSource=admin');

// Redis
const Redis = require('ioredis');
const redis = new Redis('redis://:redis@localhost:6379/0');
```

### Python Example

```python
# PostgreSQL
import psycopg2
conn = psycopg2.connect("postgresql://postgres:postgres@localhost:5432/devdb")

# MySQL
import mysql.connector
conn = mysql.connector.connect(
    host="localhost", user="mysql", password="mysql", database="devdb"
)

# MongoDB
from pymongo import MongoClient
client = MongoClient("mongodb://mongo:mongo@localhost:27017/devdb?authSource=admin")

# Redis
import redis
r = redis.Redis(host='localhost', port=6379, password='redis', decode_responses=True)
```

## License

MIT License
