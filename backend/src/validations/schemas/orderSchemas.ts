import Joi from 'joi';
import { errorCodes } from '../../utils/errors';
import { OrderStatus, OrderType, MainService, AdditionalService, PriceType, PaymentMethod } from '../../models/order';
import { ServiceType } from '../../models/service';

// Location schema that can be reused
const locationSchema = Joi.object({
  latitude: Joi.number().min(-90).max(90).required().messages({
    'number.min': errorCodes.GEOCODING_FAILED,
    'number.max': errorCodes.GEOCODING_FAILED,
    'any.required': errorCodes.GEOCODING_FAILED
  }),
  longitude: Joi.number().min(-180).max(180).required().messages({
    'number.min': errorCodes.GEOCODING_FAILED,
    'number.max': errorCodes.GEOCODING_FAILED,
    'any.required': errorCodes.GEOCODING_FAILED
  })
});

// Order item schema
export const orderItemSchema = Joi.object({
  itemType: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_ORDER_DATA,
    'string.empty': errorCodes.INVALID_ORDER_DATA
  }),
  quantity: Joi.number().integer().min(1).required().messages({
    'number.base': errorCodes.INVALID_ORDER_DATA,
    'number.integer': errorCodes.INVALID_ORDER_DATA,
    'number.min': errorCodes.INVALID_ORDER_DATA,
    'any.required': errorCodes.INVALID_ORDER_DATA
  }),
  mainService: Joi.string().valid(...Object.values(MainService)).required().messages({
    'any.only': errorCodes.INVALID_ORDER_DATA,
    'any.required': errorCodes.INVALID_ORDER_DATA
  }),
  additionalServices: Joi.array().items(
    Joi.string().valid(...Object.values(AdditionalService))
  ).messages({
    'array.base': errorCodes.INVALID_ORDER_DATA
  }),
  notes: Joi.string().max(500).messages({
    'string.max': errorCodes.VALIDATION_ERROR
  }),
  price: Joi.number().min(0).required().messages({
    'number.min': errorCodes.INVALID_PRICE_RANGE,
    'any.required': errorCodes.INVALID_PRICE_RANGE
  }),
  priceType: Joi.string().valid(...Object.values(PriceType)).required().messages({
    'any.only': errorCodes.INVALID_PRICE_RANGE,
    'any.required': errorCodes.INVALID_PRICE_RANGE
  })
});

// Create order schema
export const createOrderSchema = Joi.object({
  type: Joi.string().valid(...Object.values(OrderType)).required().messages({
    'any.only': errorCodes.INVALID_ORDER_DATA,
    'any.required': errorCodes.INVALID_ORDER_DATA
  }),
  items: Joi.array().items(orderItemSchema).min(1).required().messages({
    'array.min': errorCodes.INVALID_ORDER_DATA,
    'any.required': errorCodes.INVALID_ORDER_DATA
  }),
  pickupAddress: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_ADDRESS_DATA,
    'string.empty': errorCodes.INVALID_ADDRESS_DATA
  }),
  pickupLocation: locationSchema,
  deliveryAddress: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_ADDRESS_DATA,
    'string.empty': errorCodes.INVALID_ADDRESS_DATA
  }),
  deliveryLocation: locationSchema,
  scheduledPickupTime: Joi.date().greater('now').required().messages({
    'date.greater': errorCodes.SLOT_NOT_AVAILABLE,
    'any.required': errorCodes.SLOT_NOT_AVAILABLE
  }),
  scheduledDeliveryTime: Joi.date().greater(Joi.ref('scheduledPickupTime')).required().messages({
    'date.greater': errorCodes.SLOT_NOT_AVAILABLE,
    'any.required': errorCodes.SLOT_NOT_AVAILABLE
  }),
  specialInstructions: Joi.string().max(500).messages({
    'string.max': errorCodes.VALIDATION_ERROR
  }),
  serviceType: Joi.string().valid(...Object.values(ServiceType)).required().messages({
    'any.only': errorCodes.INVALID_ORDER_DATA,
    'any.required': errorCodes.INVALID_ORDER_DATA
  }),
  zoneId: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_ADDRESS_DATA,
    'string.empty': errorCodes.INVALID_ADDRESS_DATA
  }),
  paymentMethod: Joi.string().valid(...Object.values(PaymentMethod)).required().messages({
    'any.only': errorCodes.PAYMENT_PROCESSING_FAILED,
    'any.required': errorCodes.PAYMENT_PROCESSING_FAILED
  })
});

// Update order status schema
export const updateOrderStatusSchema = Joi.object({
  status: Joi.string().valid(...Object.values(OrderStatus)).required().messages({
    'any.only': errorCodes.INVALID_ORDER_STATUS,
    'any.required': errorCodes.INVALID_ORDER_STATUS
  }),
  deliveryPersonId: Joi.string().when('status', {
    is: Joi.string().valid(OrderStatus.PICKED_UP, OrderStatus.DELIVERING),
    then: Joi.required(),
    otherwise: Joi.optional()
  }).messages({
    'any.required': errorCodes.INVALID_ORDER_STATUS
  })
});

// Search orders schema
export const searchOrdersSchema = Joi.object({
  userId: Joi.string(),
  status: Joi.string().valid(...Object.values(OrderStatus)).messages({
    'any.only': errorCodes.INVALID_ORDER_STATUS
  }),
  type: Joi.string().valid(...Object.values(OrderType)).messages({
    'any.only': errorCodes.INVALID_ORDER_DATA
  }),
  serviceType: Joi.string().valid(...Object.values(ServiceType)).messages({
    'any.only': errorCodes.INVALID_ORDER_DATA
  }),
  zoneId: Joi.string(),
  deliveryPersonId: Joi.string(),
  startDate: Joi.date(),
  endDate: Joi.date().min(Joi.ref('startDate')).messages({
    'date.min': errorCodes.VALIDATION_ERROR
  }),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(10),
  sortBy: Joi.string().valid('createdAt', 'scheduledPickupTime', 'scheduledDeliveryTime').default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc')
});

// Order statistics schema
export const orderStatsSchema = Joi.object({
  startDate: Joi.date().required().messages({
    'any.required': errorCodes.VALIDATION_ERROR,
    'date.base': errorCodes.VALIDATION_ERROR
  }),
  endDate: Joi.date().min(Joi.ref('startDate')).required().messages({
    'date.min': errorCodes.VALIDATION_ERROR,
    'any.required': errorCodes.VALIDATION_ERROR
  }),
  zoneId: Joi.string(),
  deliveryPersonId: Joi.string(),
  groupBy: Joi.string().valid('day', 'week', 'month').required().messages({
    'any.only': errorCodes.VALIDATION_ERROR,
    'any.required': errorCodes.VALIDATION_ERROR
  })
});
