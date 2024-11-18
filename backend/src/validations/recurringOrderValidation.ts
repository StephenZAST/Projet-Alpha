import { z } from 'zod';
import { RecurringFrequency } from '../types/recurring';

const addressSchema = z.object({
  street: z.string(),
  city: z.string(),
  zipCode: z.string(),
  zone: z.string(),
  additionalInfo: z.string().optional(),
  latitude: z.number().optional(),
  longitude: z.number().optional(),
});

const orderItemSchema = z.object({
  id: z.string(),
  name: z.string(),
  quantity: z.number().positive(),
  price: z.number().positive(),
  notes: z.string().optional(),
});

const orderPreferencesSchema = z.object({
  specialInstructions: z.string().optional(),
  preferredTimeSlot: z.object({
    start: z.string(),
    end: z.string(),
  }).optional(),
  contactPreference: z.enum(['SMS', 'EMAIL', 'CALL']).optional(),
});

const baseOrderSchema = z.object({
  items: z.array(orderItemSchema),
  address: addressSchema,
  preferences: orderPreferencesSchema,
});

export const recurringOrderValidation = {
  create: z.object({
    frequency: z.nativeEnum(RecurringFrequency),
    baseOrder: baseOrderSchema,
  }),

  update: z.object({
    frequency: z.nativeEnum(RecurringFrequency).optional(),
    baseOrder: baseOrderSchema.optional(),
    isActive: z.boolean().optional(),
  }),

  params: z.object({
    id: z.string(),
  }),
};
