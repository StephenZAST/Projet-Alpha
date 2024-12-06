import Joi from 'joi';
import { NotificationType, NotificationPriority, NotificationStatus, DeliveryChannel } from '../../models/notification';

// Notification content schema
const notificationContentSchema = Joi.object({
  title: Joi.string().required().messages({
    'any.required': 'Le titre est requis'
  }),
  body: Joi.string().required().messages({
    'any.required': 'Le corps du message est requis'
  }),
  image: Joi.string().uri().messages({
    'string.uri': 'L\'URL de l\'image n\'est pas valide'
  }),
  data: Joi.object().pattern(
    Joi.string(),
    Joi.any()
  ).messages({
    'object.base': 'Les données additionnelles doivent être un objet'
  })
});

// Create notification schema
export const createNotificationSchema = Joi.object({
  userId: Joi.string().required().messages({
    'any.required': 'L\'ID de l\'utilisateur est requis'
  }),
  type: Joi.string().valid(...Object.values(NotificationType)).required().messages({
    'any.only': 'Type de notification invalide',
    'any.required': 'Le type de notification est requis'
  }),
  priority: Joi.string().valid(...Object.values(NotificationPriority)).default(NotificationPriority.NORMAL).messages({
    'any.only': 'Priorité invalide'
  }),
  content: notificationContentSchema.required(),
  channels: Joi.array().items(
    Joi.string().valid(...Object.values(DeliveryChannel))
  ).min(1).required().messages({
    'array.min': 'Au moins un canal de livraison est requis',
    'any.required': 'Les canaux de livraison sont requis'
  }),
  scheduledFor: Joi.date().min('now').messages({
    'date.min': 'La date programmée doit être dans le futur'
  }),
  expiresAt: Joi.date().min(Joi.ref('scheduledFor')).messages({
    'date.min': 'La date d\'expiration doit être après la date programmée'
  })
});

// Create bulk notifications schema
export const createBulkNotificationsSchema = Joi.object({
  userIds: Joi.array().items(Joi.string()).min(1).required().messages({
    'array.min': 'Au moins un ID d\'utilisateur est requis',
    'any.required': 'Les IDs des utilisateurs sont requis'
  }),
  notification: createNotificationSchema.fork(['userId'], schema => schema.forbidden()).required().messages({
    'any.required': 'Les détails de la notification sont requis'
  })
});

// Update notification schema
export const updateNotificationSchema = Joi.object({
  status: Joi.string().valid(...Object.values(NotificationStatus)).required().messages({
    'any.only': 'Statut invalide',
    'any.required': 'Le statut est requis'
  }),
  readAt: Joi.date().when('status', {
    is: NotificationStatus.READ,
    then: Joi.required(),
    otherwise: Joi.forbidden()
  }).messages({
    'any.required': 'La date de lecture est requise pour le statut READ',
    'any.unknown': 'La date de lecture n\'est pas autorisée pour ce statut'
  })
});

// Search notifications schema
export const searchNotificationsSchema = Joi.object({
  userId: Joi.string(),
  type: Joi.string().valid(...Object.values(NotificationType)),
  status: Joi.string().valid(...Object.values(NotificationStatus)),
  priority: Joi.string().valid(...Object.values(NotificationPriority)),
  startDate: Joi.date(),
  endDate: Joi.date().min(Joi.ref('startDate')).messages({
    'date.min': 'La date de fin doit être après la date de début'
  }),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(10),
  sortBy: Joi.string().valid('createdAt', 'scheduledFor', 'priority').default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc')
});

// Notification preferences schema
export const updateNotificationPreferencesSchema = Joi.object({
  userId: Joi.string().required().messages({
    'any.required': 'L\'ID de l\'utilisateur est requis'
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
  ).min(1).required().messages({
    'object.min': 'Au moins une préférence doit être spécifiée',
    'any.required': 'Les préférences sont requises'
  })
});
