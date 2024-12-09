import Joi from 'joi';
import { RecurringFrequency } from '../../types/recurring';

const baseOrderSchema = Joi.object({
  items: Joi.array().required(),
  address: Joi.object().required(),
  preferences: Joi.object().required(),
});

const createRecurringOrderSchema = Joi.object({
  frequency: Joi.string().valid(...Object.values(RecurringFrequency)).required(),
  baseOrder: baseOrderSchema.required(),
});

const updateRecurringOrderSchema = Joi.object({
  frequency: Joi.string().valid(...Object.values(RecurringFrequency)),
  baseOrder: baseOrderSchema,
  isActive: Joi.boolean(),
});

const cancelRecurringOrderSchema = Joi.object({
  id: Joi.string().required(),
});

const getRecurringOrdersSchema = Joi.object({
  page: Joi.number(),
  limit: Joi.number(),
  status: Joi.string().valid('active', 'cancelled', 'paused'),
});

const processRecurringOrdersSchema = Joi.object({});

export {
  createRecurringOrderSchema,
  updateRecurringOrderSchema,
  cancelRecurringOrderSchema,
  getRecurringOrdersSchema,
  processRecurringOrdersSchema,
};
