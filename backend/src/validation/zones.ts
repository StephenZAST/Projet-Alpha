import Joi from 'joi';

export const createZoneSchema: Joi.ObjectSchema = Joi.object({
  name: Joi.string().required(),
  description: Joi.string(),
  boundaries: Joi.array().items(Joi.object({
    latitude: Joi.number().min(-90).max(90).required(),
    longitude: Joi.number().min(-180).max(180).required()
  })).min(3).required(),
  deliveryFee: Joi.number().min(0).required(),
  minimumOrderAmount: Joi.number().min(0).required(),
  estimatedDeliveryTime: Joi.number().min(0).required(), // en minutes
  isActive: Joi.boolean().default(true),
  maxOrders: Joi.number().min(1).required(),
  specialInstructions: Joi.string()
});

export const updateZoneSchema: Joi.ObjectSchema = Joi.object({
  name: Joi.string(),
  description: Joi.string(),
  boundaries: Joi.array().items(Joi.object({
    latitude: Joi.number().min(-90).max(90).required(),
    longitude: Joi.number().min(-180).max(180).required()
  })).min(3),
  deliveryFee: Joi.number().min(0),
  minimumOrderAmount: Joi.number().min(0),
  estimatedDeliveryTime: Joi.number().min(0),
  isActive: Joi.boolean(),
  maxOrders: Joi.number().min(1),
  specialInstructions: Joi.string()
}).min(1);

export const assignDeliveryPersonSchema: Joi.ObjectSchema = Joi.object({
  deliveryPersonId: Joi.string().required(),
  startTime: Joi.date().required(),
  endTime: Joi.date().greater(Joi.ref('startTime')).required()
});

export const searchZonesSchema: Joi.ObjectSchema = Joi.object({
  name: Joi.string(),
  isActive: Joi.boolean(),
  deliveryPersonId: Joi.string(),
  location: Joi.object({
    latitude: Joi.number().min(-90).max(90).required(),
    longitude: Joi.number().min(-180).max(180).required()
  }),
  page: Joi.number().min(1).default(1),
  limit: Joi.number().min(1).max(100).default(10)
});

export const zoneStatsSchema: Joi.ObjectSchema = Joi.object({
  startDate: Joi.date().required(),
  endDate: Joi.date().min(Joi.ref('startDate')).required(),
  zoneId: Joi.string().required(),
  groupBy: Joi.string().valid('day', 'week', 'month').required()
});
