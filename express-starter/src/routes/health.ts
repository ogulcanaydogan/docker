import { Router } from 'express';
import { config } from '../config/env.js';

const router = Router();

router.get('/', (_req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: config.APP_VERSION,
  });
});

router.get('/ready', (_req, res) => {
  // Add database/cache connectivity checks here
  const checks: Record<string, boolean> = {
    app: true,
  };

  if (config.DATABASE_URL) {
    // TODO: Add actual database check
    checks.database = true;
  }

  if (config.REDIS_URL) {
    // TODO: Add actual Redis check
    checks.redis = true;
  }

  const allHealthy = Object.values(checks).every(Boolean);

  res.status(allHealthy ? 200 : 503).json({
    status: allHealthy ? 'ready' : 'not_ready',
    checks,
    timestamp: new Date().toISOString(),
  });
});

router.get('/live', (_req, res) => {
  res.json({ status: 'alive' });
});

export default router;
