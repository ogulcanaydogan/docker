# express-starter

Production-ready Express.js TypeScript API template with best practices, validation, and Docker support.

## Features

- Express.js 4.x with TypeScript
- Zod schema validation
- Health check endpoints (Kubernetes-ready)
- Security middleware (Helmet, CORS)
- Environment validation
- Multi-stage Docker build
- Non-root Docker user
- Graceful shutdown handling

## Quick Start

```bash
docker pull ogulcanaydogan/express-starter
docker run -p 3000:3000 ogulcanaydogan/express-starter
```

Open http://localhost:3000/health to verify it's running.

## Usage

### With Docker Compose

```bash
# Clone or copy the express-starter directory
cd express-starter

# Copy environment file
cp .env.example .env

# Start the application
docker compose up -d

# View logs
docker compose logs -f
```

### Development Mode

```bash
# Install dependencies
npm install

# Run with hot reload
npm run dev

# Or with Docker Compose
docker compose --profile dev up
```

### Production Build

```bash
# Build TypeScript
npm run build

# Start production server
npm start
```

## Project Structure

```
express-starter/
├── src/
│   ├── index.ts              # Application entry point
│   ├── config/
│   │   └── env.ts            # Environment configuration
│   ├── middleware/
│   │   └── error.ts          # Error handling middleware
│   └── routes/
│       ├── health.ts         # Health check endpoints
│       └── items.ts          # Example CRUD endpoints
├── package.json
├── tsconfig.json
├── Dockerfile
├── docker-compose.yml
└── .env.example
```

## API Endpoints

### Health Checks

| Endpoint | Description |
|----------|-------------|
| `GET /health` | Basic health check |
| `GET /health/ready` | Readiness probe (Kubernetes) |
| `GET /health/live` | Liveness probe (Kubernetes) |

### Example Items API

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/v1/items` | List items (paginated) |
| `POST` | `/api/v1/items` | Create item |
| `GET` | `/api/v1/items/:id` | Get item |
| `PATCH` | `/api/v1/items/:id` | Update item |
| `DELETE` | `/api/v1/items/:id` | Delete item |

### Query Parameters for List

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | number | 1 | Page number |
| `pageSize` | number | 10 | Items per page (max 100) |
| `activeOnly` | boolean | false | Filter active items |

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NODE_ENV` | `production` | Environment mode |
| `PORT` | `3000` | Server port |
| `APP_NAME` | `Express Starter` | Application name |
| `APP_VERSION` | `1.0.0` | Application version |
| `CORS_ORIGINS` | `*` | Allowed CORS origins |
| `LOG_LEVEL` | `info` | Logging level |
| `DATABASE_URL` | - | Database connection URL |
| `REDIS_URL` | - | Redis connection URL |

## Request Validation

Uses Zod for runtime validation:

```typescript
import { z } from 'zod';

const createItemSchema = z.object({
  name: z.string().min(1).max(100),
  description: z.string().max(500).optional(),
  price: z.number().positive(),
  isActive: z.boolean().default(true),
});

// In route handler
const data = createItemSchema.parse(req.body);
```

## Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: express-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: express-app
  template:
    metadata:
      labels:
        app: express-app
    spec:
      containers:
      - name: api
        image: ogulcanaydogan/express-starter
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: production
        livenessProbe:
          httpGet:
            path: /health/live
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          limits:
            cpu: "500m"
            memory: "256Mi"
          requests:
            cpu: "100m"
            memory: "128Mi"
---
apiVersion: v1
kind: Service
metadata:
  name: express-app
spec:
  selector:
    app: express-app
  ports:
  - port: 80
    targetPort: 3000
  type: ClusterIP
```

## Adding Database Support

### PostgreSQL with Prisma

1. Install dependencies:
```bash
npm install @prisma/client
npm install -D prisma
```

2. Initialize Prisma:
```bash
npx prisma init
```

3. Define schema in `prisma/schema.prisma` and generate client:
```bash
npx prisma generate
```

## Scripts

| Script | Description |
|--------|-------------|
| `npm run dev` | Start development server with hot reload |
| `npm run build` | Compile TypeScript to JavaScript |
| `npm start` | Start production server |
| `npm run lint` | Run ESLint |
| `npm run lint:fix` | Fix ESLint errors |
| `npm run typecheck` | Type check without emitting |

## Building

```bash
docker build -t ogulcanaydogan/express-starter .
```

## License

MIT License
