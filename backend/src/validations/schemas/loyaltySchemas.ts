import Joi from 'joi';
import { LoyaltyEventType, RewardType, RewardStatus } from '../../models/loyalty';
import { errorCodes } from '../../utils/errors';

// Points transaction schema
export const pointsTransactionSchema = Joi.object({
  userId: Joi.string().required().messages({
    'any.required': errorCodes.VALIDATION_ERROR
  }),
  points: Joi.number().integer().required().messages({
    'number.integer': errorCodes.INSUFFICIENT_POINTS,
    'any.required': errorCodes.INSUFFICIENT_POINTS
  }),
  eventType: Joi.string().valid(...Object.values(LoyaltyEventType)).required().messages({
    'any.only': errorCodes.VALIDATION_ERROR,
    'any.required': errorCodes.VALIDATION_ERROR
  }),
  referenceId: Joi.string().required().messages({
    'any.required': errorCodes.VALIDATION_ERROR
  }),
  description: Joi.string().max(200).required().messages({
    'string.max': errorCodes.VALIDATION_ERROR,
    'any.required': errorCodes.VALIDATION_ERROR
  })
});

// Create reward schema
export const createRewardSchema = Joi.object({
  name: Joi.string().required().messages({
    'any.required': errorCodes.VALIDATION_ERROR
  }),
  description: Joi.string().required().messages({
    'any.required': errorCodes.VALIDATION_ERROR
  }),
  type: Joi.string().valid(...Object.values(RewardType)).required().messages({
    'any.only': errorCodes.VALIDATION_ERROR,
    'any.required': errorCodes.VALIDATION_ERROR
  }),
  pointsCost: Joi.number().integer().min(0).required().messages({
    'number.integer': errorCodes.INSUFFICIENT_POINTS,
    'number.min': errorCodes.INSUFFICIENT_POINTS,
    'any.required': errorCodes.INSUFFICIENT_POINTS
  }),
  value: Joi.number().min(0).required().messages({
    'number.min': errorCodes.INSUFFICIENT_POINTS,
    'any.required': errorCodes.INSUFFICIENT_POINTS
  }),
  validityDays: Joi.number().integer().min(1).required().messages({
    'number.integer': errorCodes.VALIDATION_ERROR,
    'number.min': errorCodes.VALIDATION_ERROR,
    'any.required': errorCodes.VALIDATION_ERROR
  }),
  maxRedemptions: Joi.number().integer().min(0).messages({
    'number.integer': errorCodes.INSUFFICIENT_POINTS,
    'number.min': errorCodes.INSUFFICIENT_POINTS
  }),
  startDate: Joi.date().required().messages({
    'any.required': errorCodes.VALIDATION_ERROR
  }),
  endDate: Joi.date().min(Joi.ref('startDate')).messages({
    'date.min': errorCodes.VALIDATION_ERROR
  })
});

// Redeem reward schema
export const redeemRewardSchema = Joi.object({
  userId: Joi.string().required().messages({
    'any.required': errorCodes.USER_NOT_FOUND
  }),
  rewardId: Joi.string().required().messages({
    'any.required': errorCodes.REWARD_NOT_FOUND
  })
});

// Update reward redemption status schema
export const updateRedemptionStatusSchema = Joi.object({
  status: Joi.string().valid(...Object.values(RewardStatus)).required().messages({
    'any.only': errorCodes.VALIDATION_ERROR,
    'any.required': errorCodes.VALIDATION_ERROR
  }),
  notes: Joi.string().max(200)
});

// Search rewards schema
export const searchRewardsSchema = Joi.object({
  type: Joi.string().valid(...Object.values(RewardType)),
  minPoints: Joi.number().integer().min(0),
  maxPoints: Joi.number().integer().min(Joi.ref('minPoints')).messages({
    'number.min': errorCodes.INSUFFICIENT_POINTS
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
    'any.required': errorCodes.USER_NOT_FOUND
  }),
  startDate: Joi.date(),
  endDate: Joi.date().min(Joi.ref('startDate')).messages({
    'date.min': errorCodes.VALIDATION_ERROR
  })
});
