import Joi from 'joi';
import { OrderStatus, OrderType, MainService, AdditionalService, PriceType, PaymentMethod } from '../../models/order';
import { ServiceType } from '../../models/service';

// Location schema that can be reused
const locationSchema = Joi.object({
  latitude: Joi.number().min(-90).max(90).required().messages({
    'number.min': 'La latitude doit être supérieure à -90',
    'number.max': 'La latitude doit être inférieure à 90',
    'any.required': 'La latitude est requise'
  }),
  longitude: Joi.number().min(-180).max(180).required().messages({
    'number.min': 'La longitude doit être supérieure à -180',
    'number.max': 'La longitude doit être inférieure à 180',
    'any.required': 'La longitude est requise'
  })
});

// Order item schema
export const orderItemSchema = Joi.object({
  itemType: Joi.string().required().messages({
    'any.required': 'Le type d\'article est requis'
  }),
  quantity: Joi.number().min(1).required().messages({
    'number.min': 'La quantité doit être supérieure à 0',
    'any.required': 'La quantité est requise'
  }),
  mainService: Joi.string().valid(...Object.values(MainService)).required().messages({
    'any.only': 'Service principal invalide',
    'any.required': 'Le service principal est requis'
  }),
  additionalServices: Joi.array().items(
    Joi.string().valid(...Object.values(AdditionalService))
  ).messages({
    'array.base': 'Les services additionnels doivent être une liste'
  }),
  notes: Joi.string().max(500).messages({
    'string.max': 'Les notes ne peuvent pas dépasser 500 caractères'
  }),
  price: Joi.number().min(0).required().messages({
    'number.min': 'Le prix doit être supérieur ou égal à 0',
    'any.required': 'Le prix est requis'
  }),
  priceType: Joi.string().valid(...Object.values(PriceType)).required().messages({
    'any.only': 'Type de prix invalide',
    'any.required': 'Le type de prix est requis'
  })
});

// Create order schema
export const createOrderSchema = Joi.object({
  type: Joi.string().valid(...Object.values(OrderType)).required().messages({
    'any.only': 'Type de commande invalide',
    'any.required': 'Le type de commande est requis'
  }),
  items: Joi.array().items(orderItemSchema).min(1).required().messages({
    'array.min': 'Au moins un article est requis',
    'any.required': 'Les articles sont requis'
  }),
  pickupAddress: Joi.string().required().messages({
    'any.required': 'L\'adresse de ramassage est requise'
  }),
  pickupLocation: locationSchema,
  deliveryAddress: Joi.string().required().messages({
    'any.required': 'L\'adresse de livraison est requise'
  }),
  deliveryLocation: locationSchema,
  scheduledPickupTime: Joi.date().greater('now').required().messages({
    'date.greater': 'L\'heure de ramassage doit être dans le futur',
    'any.required': 'L\'heure de ramassage est requise'
  }),
  scheduledDeliveryTime: Joi.date().greater(Joi.ref('scheduledPickupTime')).required().messages({
    'date.greater': 'L\'heure de livraison doit être après l\'heure de ramassage',
    'any.required': 'L\'heure de livraison est requise'
  }),
  specialInstructions: Joi.string().max(500).messages({
    'string.max': 'Les instructions spéciales ne peuvent pas dépasser 500 caractères'
  }),
  serviceType: Joi.string().valid(...Object.values(ServiceType)).required().messages({
    'any.only': 'Type de service invalide',
    'any.required': 'Le type de service est requis'
  }),
  zoneId: Joi.string().required().messages({
    'any.required': 'L\'ID de la zone est requis'
  }),
  paymentMethod: Joi.string().valid(...Object.values(PaymentMethod)).required().messages({
    'any.only': 'Méthode de paiement invalide',
    'any.required': 'La méthode de paiement est requise'
  })
});

// Update order status schema
export const updateOrderStatusSchema = Joi.object({
  status: Joi.string().valid(...Object.values(OrderStatus)).required().messages({
    'any.only': 'Statut invalide',
    'any.required': 'Le statut est requis'
  }),
  deliveryPersonId: Joi.string().when('status', {
    is: Joi.string().valid(OrderStatus.PICKED_UP, OrderStatus.DELIVERING),
    then: Joi.required(),
    otherwise: Joi.optional()
  }).messages({
    'any.required': 'L\'ID du livreur est requis pour ce statut'
  })
});

// Search orders schema
export const searchOrdersSchema = Joi.object({
  userId: Joi.string(),
  status: Joi.string().valid(...Object.values(OrderStatus)),
  type: Joi.string().valid(...Object.values(OrderType)),
  serviceType: Joi.string().valid(...Object.values(ServiceType)),
  zoneId: Joi.string(),
  deliveryPersonId: Joi.string(),
  startDate: Joi.date(),
  endDate: Joi.date().min(Joi.ref('startDate')).messages({
    'date.min': 'La date de fin doit être après la date de début'
  }),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(10),
  sortBy: Joi.string().valid('createdAt', 'scheduledPickupTime', 'scheduledDeliveryTime').default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc')
});

// Order statistics schema
export const orderStatsSchema = Joi.object({
  startDate: Joi.date().required().messages({
    'any.required': 'La date de début est requise'
  }),
  endDate: Joi.date().min(Joi.ref('startDate')).required().messages({
    'date.min': 'La date de fin doit être après la date de début',
    'any.required': 'La date de fin est requise'
  }),
  zoneId: Joi.string(),
  deliveryPersonId: Joi.string(),
  groupBy: Joi.string().valid('day', 'week', 'month').required().messages({
    'any.only': 'Groupe invalide',
    'any.required': 'Le groupement est requis'
  })
});
