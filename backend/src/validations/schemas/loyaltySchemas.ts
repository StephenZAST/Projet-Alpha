import Joi from 'joi';
import { LoyaltyEventType, RewardType, RewardStatus } from '../../models/loyalty';

// Points transaction schema
export const pointsTransactionSchema = Joi.object({
  userId: Joi.string().required().messages({
    'any.required': 'L\'ID de l\'utilisateur est requis'
  }),
  points: Joi.number().integer().required().messages({
    'number.integer': 'Les points doivent être un nombre entier',
    'any.required': 'Les points sont requis'
  }),
  eventType: Joi.string().valid(...Object.values(LoyaltyEventType)).required().messages({
    'any.only': 'Type d\'événement invalide',
    'any.required': 'Le type d\'événement est requis'
  }),
  referenceId: Joi.string().required().messages({
    'any.required': 'L\'ID de référence est requis'
  }),
  description: Joi.string().max(200).required().messages({
    'string.max': 'La description ne peut pas dépasser 200 caractères',
    'any.required': 'La description est requise'
  })
});

// Create reward schema
export const createRewardSchema = Joi.object({
  name: Joi.string().required().messages({
    'any.required': 'Le nom est requis'
  }),
  description: Joi.string().required().messages({
    'any.required': 'La description est requise'
  }),
  type: Joi.string().valid(...Object.values(RewardType)).required().messages({
    'any.only': 'Type de récompense invalide',
    'any.required': 'Le type de récompense est requis'
  }),
  pointsCost: Joi.number().integer().min(0).required().messages({
    'number.integer': 'Le coût en points doit être un nombre entier',
    'number.min': 'Le coût en points doit être positif ou nul',
    'any.required': 'Le coût en points est requis'
  }),
  value: Joi.number().min(0).required().messages({
    'number.min': 'La valeur doit être positive ou nulle',
    'any.required': 'La valeur est requise'
  }),
  validityDays: Joi.number().integer().min(1).required().messages({
    'number.integer': 'La validité doit être un nombre entier',
    'number.min': 'La validité doit être d\'au moins 1 jour',
    'any.required': 'La validité est requise'
  }),
  maxRedemptions: Joi.number().integer().min(0).messages({
    'number.integer': 'Le nombre maximum de rachats doit être un nombre entier',
    'number.min': 'Le nombre maximum de rachats doit être positif ou nul'
  }),
  startDate: Joi.date().required().messages({
    'any.required': 'La date de début est requise'
  }),
  endDate: Joi.date().min(Joi.ref('startDate')).messages({
    'date.min': 'La date de fin doit être après la date de début'
  })
});

// Redeem reward schema
export const redeemRewardSchema = Joi.object({
  userId: Joi.string().required().messages({
    'any.required': 'L\'ID de l\'utilisateur est requis'
  }),
  rewardId: Joi.string().required().messages({
    'any.required': 'L\'ID de la récompense est requis'
  })
});

// Update reward redemption status schema
export const updateRedemptionStatusSchema = Joi.object({
  status: Joi.string().valid(...Object.values(RewardStatus)).required().messages({
    'any.only': 'Statut invalide',
    'any.required': 'Le statut est requis'
  }),
  notes: Joi.string().max(200)
});

// Search rewards schema
export const searchRewardsSchema = Joi.object({
  type: Joi.string().valid(...Object.values(RewardType)),
  minPoints: Joi.number().integer().min(0),
  maxPoints: Joi.number().integer().min(Joi.ref('minPoints')).messages({
    'number.min': 'Le maximum de points doit être supérieur au minimum'
  }),
  active: Joi.boolean(),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(10),
  sortBy: Joi.string().valid('createdAt', 'pointsCost', 'value').default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc')
});

// Get user loyalty status schema
export const userLoyaltyQuerySchema = Joi.object({
  userId: Joi.string().required().messages({
    'any.required': 'L\'ID de l\'utilisateur est requis'
  }),
  startDate: Joi.date(),
  endDate: Joi.date().min(Joi.ref('startDate')).messages({
    'date.min': 'La date de fin doit être après la date de début'
  })
});
