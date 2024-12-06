import Joi from 'joi';
import { NotificationType, NotificationPriority, NotificationStatus, DeliveryChannel } from '../../models/notification';
import { errorCodes } from '../../utils/errors';

// Notification content schema
const notificationContentSchema = Joi.object({
  title: Joi.string().required().max(100)
    .messages({
      'any.required': errorCodes.VALIDATION_ERROR,
      'string.empty': errorCodes.VALIDATION_ERROR,
      'string.max': errorCodes.VALIDATION_ERROR
    }),
  body: Joi.string().required().max(500)
    .messages({
      'any.required': errorCodes.VALIDATION_ERROR,
      'string.empty': errorCodes.VALIDATION_ERROR,
      'string.max': errorCodes.VALIDATION_ERROR
    }),
  image: Joi.string().uri()
    .messages({
      'string.uri': errorCodes.VALIDATION_ERROR
    }),
  data: Joi.object().pattern(
    Joi.string(),
    Joi.any()
  ).messages({
    'object.base': errorCodes.VALIDATION_ERROR
  })
});

// Create notification schema
export const createNotificationSchema = Joi.object({
  userId: Joi.string().required()
    .messages({
      'any.required': errorCodes.USER_NOT_FOUND,
      'string.empty': errorCodes.USER_NOT_FOUND
    }),
  type: Joi.string().valid(...Object.values(NotificationType)).required()
    .messages({
      'any.required': errorCodes.VALIDATION_ERROR,
      'any.only': errorCodes.VALIDATION_ERROR
    }),
  priority: Joi.string().valid(...Object.values(NotificationPriority)).default(NotificationPriority.NORMAL)
    .messages({
      'any.only': errorCodes.VALIDATION_ERROR
    }),
  content: notificationContentSchema.required(),
  channels: Joi.array().items(
    Joi.string().valid(...Object.values(DeliveryChannel))
  ).min(1).required()
    .messages({
      'array.min': errorCodes.VALIDATION_ERROR,
      'any.required': errorCodes.VALIDATION_ERROR
    }),
  scheduledFor: Joi.date().min('now')
    .messages({
      'date.min': errorCodes.VALIDATION_ERROR
    }),
  expiresAt: Joi.date().min(Joi.ref('scheduledFor'))
    .messages({
      'date.min': errorCodes.VALIDATION_ERROR
    })
});

// Create bulk notifications schema
export const createBulkNotificationsSchema = Joi.object({
  userIds: Joi.array().items(Joi.string()).min(1).required()
    .messages({
      'array.min': errorCodes.VALIDATION_ERROR,
      'any.required': errorCodes.VALIDATION_ERROR
    }),
  notification: createNotificationSchema.fork(['userId'], schema => schema.forbidden()).required()
    .messages({
      'any.required': errorCodes.VALIDATION_ERROR
    })
});

// Update notification schema
export const updateNotificationSchema = Joi.object({
  status: Joi.string().valid(...Object.values(NotificationStatus)).required()
    .messages({
      'any.only': errorCodes.INVALID_STATUS,
      'any.required': errorCodes.VALIDATION_ERROR
    }),
  readAt: Joi.date().when('status', {
    is: NotificationStatus.READ,
    then: Joi.required(),
    otherwise: Joi.forbidden()
  }).messages({
    'any.required': errorCodes.VALIDATION_ERROR,
    'any.unknown': errorCodes.VALIDATION_ERROR
  })
}).min(1).messages({
  'object.min': errorCodes.VALIDATION_ERROR
});

// Search notifications schema
export const searchNotificationsSchema = Joi.object({
  userId: Joi.string()
    .messages({
      'string.empty': errorCodes.USER_NOT_FOUND
    }),
  type: Joi.string().valid(...Object.values(NotificationType))
    .messages({
      'any.only': errorCodes.VALIDATION_ERROR
    }),
  status: Joi.string().valid(...Object.values(NotificationStatus))
    .messages({
      'any.only': errorCodes.INVALID_STATUS
    }),
  priority: Joi.string().valid(...Object.values(NotificationPriority))
    .messages({
      'any.only': errorCodes.VALIDATION_ERROR
    }),
  startDate: Joi.date(),
  endDate: Joi.date().min(Joi.ref('startDate'))
    .messages({
      'date.min': errorCodes.VALIDATION_ERROR
    }),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(10),
  sortBy: Joi.string().valid('createdAt', 'scheduledFor', 'priority').default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc')
}).messages({
  'object.unknown': errorCodes.VALIDATION_ERROR
});

// Notification preferences schema
export const updateNotificationPreferencesSchema = Joi.object({
  userId: Joi.string().required()
    .messages({
      'any.required': errorCodes.USER_NOT_FOUND,
      'string.empty': errorCodes.USER_NOT_FOUND
    }),
  preferences: Joi.object().pattern(
    Joi.string().valid(...Object.values(NotificationType)),
    Joi.object({
      enabled: Joi.boolean().required(),
      channels: Joi.array().items(
        Joi.string().valid(...Object.values(DeliveryChannel))
      ).when('enabled', {
        is: true,
        then: Joi.array().min(1).required(),
        otherwise: Joi.array().max(0)
      })
    })
  ).min(1).required()
    .messages({
      'object.min': errorCodes.VALIDATION_ERROR,
      'any.required': errorCodes.VALIDATION_ERROR
    })
});
