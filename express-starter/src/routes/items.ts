import { Router } from 'express';
import { z } from 'zod';
import { createError } from '../middleware/error.js';

const router = Router();

// In-memory storage for demo
const items = new Map<number, Item>();
let counter = 0;

// Schemas
const createItemSchema = z.object({
  name: z.string().min(1).max(100),
  description: z.string().max(500).optional(),
  price: z.number().positive(),
  isActive: z.boolean().default(true),
});

const updateItemSchema = createItemSchema.partial();

const querySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  pageSize: z.coerce.number().int().min(1).max(100).default(10),
  activeOnly: z.coerce.boolean().default(false),
});

interface Item {
  id: number;
  name: string;
  description?: string;
  price: number;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

// List items
router.get('/', (req, res) => {
  const query = querySchema.parse(req.query);

  let itemList = Array.from(items.values());

  if (query.activeOnly) {
    itemList = itemList.filter((item) => item.isActive);
  }

  const total = itemList.length;
  const totalPages = Math.ceil(total / query.pageSize);
  const start = (query.page - 1) * query.pageSize;
  const paginatedItems = itemList.slice(start, start + query.pageSize);

  res.json({
    items: paginatedItems,
    total,
    page: query.page,
    pageSize: query.pageSize,
    totalPages,
  });
});

// Create item
router.post('/', (req, res) => {
  const data = createItemSchema.parse(req.body);

  counter += 1;
  const now = new Date();

  const item: Item = {
    id: counter,
    name: data.name,
    description: data.description,
    price: data.price,
    isActive: data.isActive,
    createdAt: now,
    updatedAt: now,
  };

  items.set(counter, item);

  res.status(201).json(item);
});

// Get item
router.get('/:id', (req, res, next) => {
  const id = parseInt(req.params.id, 10);
  const item = items.get(id);

  if (!item) {
    return next(createError('Item not found', 404));
  }

  res.json(item);
});

// Update item
router.patch('/:id', (req, res, next) => {
  const id = parseInt(req.params.id, 10);
  const item = items.get(id);

  if (!item) {
    return next(createError('Item not found', 404));
  }

  const updates = updateItemSchema.parse(req.body);

  const updatedItem: Item = {
    ...item,
    ...updates,
    updatedAt: new Date(),
  };

  items.set(id, updatedItem);

  res.json(updatedItem);
});

// Delete item
router.delete('/:id', (req, res, next) => {
  const id = parseInt(req.params.id, 10);

  if (!items.has(id)) {
    return next(createError('Item not found', 404));
  }

  items.delete(id);
  res.status(204).send();
});

export default router;
