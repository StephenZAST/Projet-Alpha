import Joi from 'joi';
import { OrderStatus, OrderType, MainService } from '../models/order';

// Schéma pour les articles de la commande
export const orderItemSchema = Joi.object({
  id: Joi.string().required(),
  name: Joi.string().required(),
  quantity: Joi.number().min(1).required(),
  price: Joi.number().min(0).required(),
  notes: Joi.string()
});

// Schéma pour la création d'une commande standard
export const createOrderSchema = Joi.object({
  userId: Joi.string().required(),
  type: Joi.string().valid(...Object.values(OrderType)).required(),
  items: Joi.array().items(orderItemSchema).min(1).required(),
  totalAmount: Joi.number().min(0).required(),
  scheduledPickupTime: Joi.date().required(),
  scheduledDeliveryTime: Joi.date().required(),
  pickupAddress: Joi.string().required(),
  deliveryAddress: Joi.string().required(),
  pickupLocation: Joi.object({
    latitude: Joi.number().required(),
    longitude: Joi.number().required()
  }).required(),
  deliveryLocation: Joi.object({
    latitude: Joi.number().required(),
    longitude: Joi.number().required()
  }).required(),
  zoneId: Joi.string().required(),
  specialInstructions: Joi.string(),
  paymentMethod: Joi.string()
});

// Schéma pour la mise à jour du statut d'une commande
export const updateOrderStatusSchema = Joi.object({
  status: Joi.string().valid(...Object.values(OrderStatus)).required(),
  deliveryPersonId: Joi.string().when('status', {
    is: OrderStatus.ACCEPTED,
    then: Joi.required(),
    otherwise: Joi.optional()
  })
});

// Schéma pour la recherche de commandes
export const searchOrdersSchema = Joi.object({
  userId: Joi.string(),
  status: Joi.string().valid(...Object.values(OrderStatus)),
  zoneId: Joi.string(),
  startDate: Joi.date(),
  endDate: Joi.date().min(Joi.ref('startDate')),
  page: Joi.number().min(1).default(1),
  limit: Joi.number().min(1).max(100).default(10)
});

// Schéma pour les statistiques des commandes
export const orderStatsSchema = Joi.object({
  startDate: Joi.date().required(),
  endDate: Joi.date().min(Joi.ref('startDate')).required(),
  zoneId: Joi.string(),
  deliveryPersonId: Joi.string(),
  groupBy: Joi.string().valid('day', 'week', 'month').required()
});

// Interface pour le résultat de validation
export interface ValidationResult {
  isValid: boolean;
  errors: string[];
}

// Validate order data using the createOrderSchema
export function validateOrderData(orderData: any): ValidationResult {
  const validationResult = createOrderSchema.validate(orderData, { abortEarly: false });
  
  if (validationResult.error) {
    return {
      isValid: false,
      errors: validationResult.error.details.map(detail => detail.message)
    };
  }

  return {
    isValid: true,
    errors: []
  };
}