import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';

import { config } from './config/env.js';
import { errorHandler, notFoundHandler } from './middleware/error.js';
import healthRouter from './routes/health.js';
import itemsRouter from './routes/items.js';

const app = express();

// Security middleware
app.use(helmet());
app.use(cors({
  origin: config.CORS_ORIGINS,
  credentials: true,
}));

// Request parsing
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging
if (config.NODE_ENV !== 'test') {
  app.use(morgan(config.NODE_ENV === 'development' ? 'dev' : 'combined'));
}

// Routes
app.get('/', (_req, res) => {
  res.json({
    app: config.APP_NAME,
    version: config.APP_VERSION,
    environment: config.NODE_ENV,
    docs: '/docs',
  });
});

app.use('/health', healthRouter);
app.use('/api/v1/items', itemsRouter);

// Error handling
app.use(notFoundHandler);
app.use(errorHandler);

// Start server
const server = app.listen(config.PORT, () => {
  console.log(`
╔══════════════════════════════════════════════════════════════╗
║                    ${config.APP_NAME.padEnd(36)}  ║
╚══════════════════════════════════════════════════════════════╝

  Environment: ${config.NODE_ENV}
  Server:      http://localhost:${config.PORT}
  Health:      http://localhost:${config.PORT}/health

  Press Ctrl+C to stop
`);
});

// Graceful shutdown
const shutdown = () => {
  console.log('\nShutting down gracefully...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });

  // Force close after 10s
  setTimeout(() => {
    console.error('Forcing shutdown');
    process.exit(1);
  }, 10000);
};

process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);

export default app;
