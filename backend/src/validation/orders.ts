import Joi from 'joi';
import { OrderStatus, OrderType, ServiceType } from '../models/order';

// Schéma pour la géolocalisation
const locationSchema = Joi.object({
  latitude: Joi.number().required().min(-90).max(90),
  longitude: Joi.number().required().min(-180).max(180)
});

// Schéma pour les articles de la commande
const orderItemSchema = Joi.object({
  itemType: Joi.string().required(),
  quantity: Joi.number().required().min(1),
  notes: Joi.string().allow(''),
  price: Joi.number().min(0)
});

// Schéma pour la création d'une commande standard
export const createOrderSchema = Joi.object({
  userId: Joi.string().required(),
  type: Joi.string().valid(...Object.values(OrderType)).required(),
  serviceType: Joi.string().valid(...Object.values(ServiceType)).required(),
  items: Joi.array().items(orderItemSchema).min(1).required(),
  pickupAddress: Joi.string().required(),
  pickupLocation: locationSchema.required(),
  deliveryAddress: Joi.string().required(),
  deliveryLocation: locationSchema.required(),
  scheduledPickupTime: Joi.date().min('now').required(),
  scheduledDeliveryTime: Joi.date().min(Joi.ref('scheduledPickupTime')).required(),
  specialInstructions: Joi.string().allow(''),
  zoneId: Joi.string().required(),
  estimatedPrice: Joi.number().min(0)
});

// Schéma pour la création d'une commande one-click
export const createOneClickOrderSchema = Joi.object({
  userId: Joi.string().required(),
  zoneId: Joi.string().required(),
  specialInstructions: Joi.string().allow('')
});

// Schéma pour la mise à jour du statut d'une commande
export const updateOrderStatusSchema = Joi.object({
  status: Joi.string().valid(...Object.values(OrderStatus)).required(),
  deliveryPersonId: Joi.string().when('status', {
    is: OrderStatus.ACCEPTED,
    then: Joi.required(),
    otherwise: Joi.optional()
  }),
  notes: Joi.string().allow('')
});

// Schéma pour la recherche de commandes
export const searchOrdersSchema = Joi.object({
  startDate: Joi.date(),
  endDate: Joi.date().min(Joi.ref('startDate')),
  status: Joi.string().valid(...Object.values(OrderStatus)),
  zoneId: Joi.string(),
  deliveryPersonId: Joi.string(),
  page: Joi.number().min(1).default(1),
  limit: Joi.number().min(1).max(100).default(10)
});

// Schéma pour les statistiques des commandes
export const orderStatsSchema = Joi.object({
  startDate: Joi.date().required(),
  endDate: Joi.date().min(Joi.ref('startDate')).required(),
  zoneId: Joi.string(),
  deliveryPersonId: Joi.string()
});
