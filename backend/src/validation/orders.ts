import Joi from 'joi';
import { OrderStatus, OrderType, MainService, AdditionalService, PriceType, ServiceType } from '../models/order';

// Schéma pour les articles de la commande
export const orderItemSchema = Joi.object({
  itemType: Joi.string().required(),
  quantity: Joi.number().min(1).required(),
  mainService: Joi.string().valid(...Object.values(MainService)).required(),
  additionalServices: Joi.array().items(Joi.string().valid(...Object.values(AdditionalService))),
  notes: Joi.string(),
  price: Joi.number().min(0).required(),
  priceType: Joi.string().valid(...Object.values(PriceType)).required()
});

// Schéma pour la création d'une commande standard
export const createOrderSchema: Joi.ObjectSchema = Joi.object({
  type: Joi.string().valid(...Object.values(OrderType)).required(),
  items: Joi.array().items(orderItemSchema).min(1).required(),
  pickupAddress: Joi.string().required(),
  pickupLocation: Joi.object({
    latitude: Joi.number().min(-90).max(90).required(),
    longitude: Joi.number().min(-180).max(180).required()
  }).required(),
  deliveryAddress: Joi.string().required(),
  deliveryLocation: Joi.object({
    latitude: Joi.number().min(-90).max(90).required(),
    longitude: Joi.number().min(-180).max(180).required()
  }).required(),
  scheduledPickupTime: Joi.date().greater('now').required(),
  scheduledDeliveryTime: Joi.date().greater(Joi.ref('scheduledPickupTime')).required(),
  specialInstructions: Joi.string(),
  serviceType: Joi.string().valid(...Object.values(ServiceType)).required(),
  zoneId: Joi.string().required()
});

// Schéma pour la mise à jour du statut d'une commande
export const updateOrderStatusSchema: Joi.ObjectSchema = Joi.object({
  status: Joi.string().valid(...Object.values(OrderStatus)).required(),
  deliveryPersonId: Joi.string().when('status', {
    is: Joi.string().valid(OrderStatus.PICKED_UP, OrderStatus.DELIVERING),
    then: Joi.required(),
    otherwise: Joi.optional()
  })
});

// Schéma pour la recherche de commandes
export const searchOrdersSchema: Joi.ObjectSchema = Joi.object({
  userId: Joi.string(),
  status: Joi.string().valid(...Object.values(OrderStatus)),
  type: Joi.string().valid(...Object.values(OrderType)),
  serviceType: Joi.string().valid(...Object.values(ServiceType)),
  zoneId: Joi.string(),
  deliveryPersonId: Joi.string(),
  startDate: Joi.date(),
  endDate: Joi.date().min(Joi.ref('startDate')),
  page: Joi.number().min(1).default(1),
  limit: Joi.number().min(1).max(100).default(10)
});

// Schéma pour les statistiques des commandes
export const orderStatsSchema: Joi.ObjectSchema = Joi.object({
  startDate: Joi.date().required(),
  endDate: Joi.date().min(Joi.ref('startDate')).required(),
  zoneId: Joi.string(),
  deliveryPersonId: Joi.string(),
  groupBy: Joi.string().valid('day', 'week', 'month').required()
});
