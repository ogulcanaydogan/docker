import 'dotenv/config';
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('production'),
  PORT: z.coerce.number().default(3000),
  APP_NAME: z.string().default('Express Starter'),
  APP_VERSION: z.string().default('1.0.0'),
  CORS_ORIGINS: z.string().transform((val) => {
    try {
      return JSON.parse(val) as string[];
    } catch {
      return val.split(',').map((s) => s.trim());
    }
  }).default('*'),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
  DATABASE_URL: z.string().optional(),
  REDIS_URL: z.string().optional(),
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('❌ Invalid environment variables:');
  console.error(parsed.error.format());
  process.exit(1);
}

export const config = parsed.data;

export type Config = z.infer<typeof envSchema>;
