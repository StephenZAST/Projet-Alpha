import Joi from 'joi';
import { OrderStatus, OrderType, MainService, AdditionalService, PriceType, PaymentMethod, ServiceType } from '../models/order';

// Define the ServiceType enum
export enum ServiceType {
  STANDARD = 'standard',
  EXPRESS = 'express',
  // Add any other service types you need
}

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

// Schéma pour la création d'une commande
export const createOrderSchemaNew = Joi.object({
  items: Joi.array().items(
    Joi.object({
      serviceType: Joi.string().valid(...Object.values(ServiceType)).required().messages({
        'any.required': 'Le type de service est requis',
        'any.only': 'Type de service invalide'
      }),
      quantity: Joi.number().integer().min(1).required().messages({
        'number.base': 'La quantité doit être un nombre',
        'number.integer': 'La quantité doit être un nombre entier',
        'number.min': 'La quantité doit être supérieure à 0',
        'any.required': 'La quantité est requise'
      }),
      notes: Joi.string().max(500)
    })
  ).min(1).required().messages({
    'array.min': 'Au moins un article est requis',
    'any.required': 'Les articles sont requis'
  }),
  pickupAddress: Joi.object({
    street: Joi.string().required(),
    city: Joi.string().required(),
    postalCode: Joi.string(),
    country: Joi.string().required(),
    latitude: Joi.number().required(),
    longitude: Joi.number().required(),
    additionalInfo: Joi.string()
  }).required().messages({
    'any.required': 'L\'adresse de ramassage est requise'
  }),
  deliveryAddress: Joi.object({
    street: Joi.string().required(),
    city: Joi.string().required(),
    postalCode: Joi.string(),
    country: Joi.string().required(),
    latitude: Joi.number().required(),
    longitude: Joi.number().required(),
    additionalInfo: Joi.string()
  }).required().messages({
    'any.required': 'L\'adresse de livraison est requise'
  }),
  scheduledPickupTime: Joi.date().iso().greater('now').required().messages({
    'date.base': 'La date de ramassage doit être une date valide',
    'date.greater': 'La date de ramassage doit être dans le futur',
    'any.required': 'La date de ramassage est requise'
  }),
  paymentMethod: Joi.string().valid(...Object.values(PaymentMethod)).required().messages({
    'any.required': 'La méthode de paiement est requise',
    'any.only': 'Méthode de paiement invalide'
  }),
  specialInstructions: Joi.string().max(1000)
});

// Schéma pour la mise à jour d'une commande
export const updateOrderSchema = Joi.object({
  items: Joi.array().items(
    Joi.object({
      serviceType: Joi.string().valid(...Object.values(ServiceType)),
      quantity: Joi.number().integer().min(1),
      notes: Joi.string().max(500)
    })
  ),
  pickupAddress: Joi.object({
    street: Joi.string(),
    city: Joi.string(),
    postalCode: Joi.string(),
    country: Joi.string(),
    latitude: Joi.number(),
    longitude: Joi.number(),
    additionalInfo: Joi.string()
  }),
  deliveryAddress: Joi.object({
    street: Joi.string(),
    city: Joi.string(),
    postalCode: Joi.string(),
    country: Joi.string(),
    latitude: Joi.number(),
    longitude: Joi.number(),
    additionalInfo: Joi.string()
  }),
  scheduledPickupTime: Joi.date().iso().greater('now'),
  paymentMethod: Joi.string().valid(...Object.values(PaymentMethod)),
  specialInstructions: Joi.string().max(1000)
}).min(1).messages({
  'object.min': 'Au moins un champ doit être fourni pour la mise à jour'
});

// Schéma pour la mise à jour du statut d'une commande
export const updateOrderStatusSchemaNew = Joi.object({
  status: Joi.string().valid(...Object.values(OrderStatus)).required().messages({
    'any.required': 'Le statut est requis',
    'any.only': 'Statut invalide'
  }),
  reason: Joi.string().max(500).when('status', {
    is: OrderStatus.CANCELLED,
    then: Joi.required(),
    otherwise: Joi.optional()
  }).messages({
    'any.required': 'La raison est requise pour l\'annulation',
    'string.max': 'La raison ne peut pas dépasser 500 caractères'
  })
});

// Validate order data using the createOrderSchema
export function validateOrderData(orderData: any): OrderValidationResult {
  const { error } = createOrderSchemaNew.validate(orderData);
  return {
    isValid: !error,
    errors: error ? [error.details[0].message] : []
  };
}

export interface OrderValidationResult {
  isValid: boolean;
  errors: string[];
}
