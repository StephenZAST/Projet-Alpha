import Joi from 'joi';
import { MetricType, TimeFrame, AggregationType } from '../../models/analytics';

// Base date range schema
const dateRangeSchema = Joi.object({
  startDate: Joi.date().required().messages({
    'any.required': 'La date de début est requise'
  }),
  endDate: Joi.date().min(Joi.ref('startDate')).required().messages({
    'date.min': 'La date de fin doit être après la date de début',
    'any.required': 'La date de fin est requise'
  })
});

// Metric query schema
export const metricQuerySchema = Joi.object({
  ...dateRangeSchema.extract(),
  metricType: Joi.string().valid(...Object.values(MetricType)).required().messages({
    'any.only': 'Type de métrique invalide',
    'any.required': 'Le type de métrique est requis'
  }),
  timeFrame: Joi.string().valid(...Object.values(TimeFrame)).required().messages({
    'any.only': 'Période invalide',
    'any.required': 'La période est requise'
  }),
  aggregationType: Joi.string().valid(...Object.values(AggregationType)).default(AggregationType.SUM).messages({
    'any.only': 'Type d\'agrégation invalide'
  }),
  filters: Joi.object({
    zoneId: Joi.string(),
    categoryId: Joi.string(),
    userId: Joi.string(),
    serviceType: Joi.string(),
    paymentMethod: Joi.string()
  })
});

// Dashboard metrics schema
export const dashboardMetricsSchema = Joi.object({
  timeFrame: Joi.string().valid(...Object.values(TimeFrame)).required().messages({
    'any.only': 'Période invalide',
    'any.required': 'La période est requise'
  }),
  metrics: Joi.array().items(
    Joi.string().valid(...Object.values(MetricType))
  ).min(1).required().messages({
    'array.min': 'Au moins une métrique est requise',
    'any.required': 'Les métriques sont requises'
  })
});

// Custom report schema
export const customReportSchema = Joi.object({
  name: Joi.string().required().messages({
    'any.required': 'Le nom est requis'
  }),
  description: Joi.string(),
  metrics: Joi.array().items(
    Joi.object({
      type: Joi.string().valid(...Object.values(MetricType)).required(),
      aggregationType: Joi.string().valid(...Object.values(AggregationType)).required()
    })
  ).min(1).required().messages({
    'array.min': 'Au moins une métrique est requise',
    'any.required': 'Les métriques sont requises'
  }),
  timeFrame: Joi.string().valid(...Object.values(TimeFrame)).required().messages({
    'any.only': 'Période invalide',
    'any.required': 'La période est requise'
  }),
  filters: Joi.object({
    zoneIds: Joi.array().items(Joi.string()),
    categoryIds: Joi.array().items(Joi.string()),
    userIds: Joi.array().items(Joi.string()),
    serviceTypes: Joi.array().items(Joi.string()),
    paymentMethods: Joi.array().items(Joi.string())
  }),
  schedule: Joi.object({
    frequency: Joi.string().valid('daily', 'weekly', 'monthly').required(),
    time: Joi.string().pattern(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/).required(),
    recipients: Joi.array().items(
      Joi.string().email()
    ).min(1).required()
  })
});

// Export data schema
export const exportDataSchema = Joi.object({
  ...dateRangeSchema.extract(),
  dataType: Joi.string().valid('orders', 'users', 'transactions', 'deliveries').required().messages({
    'any.only': 'Type de données invalide',
    'any.required': 'Le type de données est requis'
  }),
  format: Joi.string().valid('csv', 'excel', 'json').default('csv').messages({
    'any.only': 'Format invalide'
  }),
  filters: Joi.object({
    zoneIds: Joi.array().items(Joi.string()),
    categoryIds: Joi.array().items(Joi.string()),
    userIds: Joi.array().items(Joi.string()),
    serviceTypes: Joi.array().items(Joi.string()),
    paymentMethods: Joi.array().items(Joi.string())
  }),
  fields: Joi.array().items(Joi.string())
});

// Real-time metrics schema
export const realTimeMetricsSchema = Joi.object({
  metrics: Joi.array().items(
    Joi.string().valid(...Object.values(MetricType))
  ).min(1).required().messages({
    'array.min': 'Au moins une métrique est requise',
    'any.required': 'Les métriques sont requises'
  }),
  interval: Joi.number().integer().min(5).max(60).default(15).messages({
    'number.min': 'L\'intervalle minimum est de 5 secondes',
    'number.max': 'L\'intervalle maximum est de 60 secondes'
  })
});
