import Joi from 'joi';
import { RecurringFrequency } from '../types/recurring';

const addressSchema = Joi.object({
  street: Joi.string().required(),
  city: Joi.string().required(),
  zipCode: Joi.string().required(),
  zone: Joi.string().required(),
  additionalInfo: Joi.string().optional(),
  latitude: Joi.number().optional(),
  longitude: Joi.number().optional(),
});

const orderItemSchema = Joi.object({
  id: Joi.string().required(),
  name: Joi.string().required(),
  quantity: Joi.number().positive().required(),
  price: Joi.number().positive().required(),
  notes: Joi.string().optional(),
});

const orderPreferencesSchema = Joi.object({
  specialInstructions: Joi.string().optional(),
  preferredTimeSlot: Joi.object({
    start: Joi.string().required(),
    end: Joi.string().required(),
  }).optional(),
  contactPreference: Joi.string().valid('SMS', 'EMAIL', 'CALL').optional(),
});

const baseOrderSchema = Joi.object({
  items: Joi.array().items(orderItemSchema).required(),
  address: addressSchema.required(),
  preferences: orderPreferencesSchema.required(),
});

export const recurringOrderValidation = {
  create: Joi.object({
    frequency: Joi.string().valid(...Object.values(RecurringFrequency)).required(),
    baseOrder: baseOrderSchema,
  }),

  update: Joi.object({
    frequency: Joi.string().valid(...Object.values(RecurringFrequency)).optional(),
    baseOrder: baseOrderSchema.optional(),
    isActive: Joi.boolean().optional(),
  }),

  params: Joi.object({
    id: Joi.string().required(),
  }),
};
