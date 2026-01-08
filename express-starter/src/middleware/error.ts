import type { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';
import { config } from '../config/env.js';

export interface AppError extends Error {
  statusCode?: number;
  isOperational?: boolean;
}

export const createError = (message: string, statusCode: number): AppError => {
  const error: AppError = new Error(message);
  error.statusCode = statusCode;
  error.isOperational = true;
  return error;
};

export const notFoundHandler = (_req: Request, _res: Response, next: NextFunction) => {
  next(createError('Resource not found', 404));
};

export const errorHandler = (
  err: AppError,
  _req: Request,
  res: Response,
  _next: NextFunction
) => {
  // Handle Zod validation errors
  if (err instanceof ZodError) {
    res.status(400).json({
      error: 'Validation Error',
      details: err.errors.map((e) => ({
        path: e.path.join('.'),
        message: e.message,
      })),
    });
    return;
  }

  const statusCode = err.statusCode || 500;
  const message = err.isOperational ? err.message : 'Internal Server Error';

  // Log error in development
  if (config.NODE_ENV === 'development') {
    console.error('Error:', err);
  }

  res.status(statusCode).json({
    error: message,
    ...(config.NODE_ENV === 'development' && { stack: err.stack }),
  });
};
