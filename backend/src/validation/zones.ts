import Joi from 'joi';

// Schéma pour les points de délimitation d'une zone
const boundaryPointSchema = Joi.object({
  latitude: Joi.number().required().min(-90).max(90),
  longitude: Joi.number().required().min(-180).max(180)
});

// Schéma pour la création d'une zone
export const createZoneSchema = Joi.object({
  name: Joi.string().required().min(3).max(50),
  description: Joi.string().allow(''),
  boundaries: Joi.array().items(boundaryPointSchema).min(3).required(),
  isActive: Joi.boolean().default(true),
  deliveryPersonIds: Joi.array().items(Joi.string()),
  estimatedDeliveryTime: Joi.number().min(0).required(), // en minutes
  baseDeliveryFee: Joi.number().min(0).required(),
  rushHourMultiplier: Joi.number().min(1).max(5).default(1.5),
  rushHourStart: Joi.string().pattern(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
  rushHourEnd: Joi.string().pattern(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
});

// Schéma pour la mise à jour d'une zone
export const updateZoneSchema = Joi.object({
  name: Joi.string().min(3).max(50),
  description: Joi.string().allow(''),
  boundaries: Joi.array().items(boundaryPointSchema).min(3),
  isActive: Joi.boolean(),
  deliveryPersonIds: Joi.array().items(Joi.string()),
  estimatedDeliveryTime: Joi.number().min(0),
  baseDeliveryFee: Joi.number().min(0),
  rushHourMultiplier: Joi.number().min(1).max(5),
  rushHourStart: Joi.string().pattern(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
  rushHourEnd: Joi.string().pattern(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
}).min(1);

// Schéma pour l'attribution de livreurs à une zone
export const assignDeliveryPersonsSchema = Joi.object({
  deliveryPersonIds: Joi.array().items(Joi.string()).required()
});

// Schéma pour la recherche de zones
export const searchZonesSchema = Joi.object({
  isActive: Joi.boolean(),
  deliveryPersonId: Joi.string(),
  page: Joi.number().min(1).default(1),
  limit: Joi.number().min(1).max(100).default(10)
});

// Schéma pour les statistiques des zones
export const zoneStatsSchema = Joi.object({
  startDate: Joi.date().required(),
  endDate: Joi.date().min(Joi.ref('startDate')).required(),
  includeInactive: Joi.boolean().default(false)
});
