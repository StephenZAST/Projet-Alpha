import Joi from 'joi';
import { AffiliateStatus, CommissionType, PayoutStatus } from '../../models/affiliate';
import { errorCodes } from '../../utils/errors';

// Bank account schema
const bankAccountSchema = Joi.object({
  accountName: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_USER_DATA,
    'string.empty': errorCodes.INVALID_USER_DATA
  }),
  accountNumber: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_USER_DATA,
    'string.empty': errorCodes.INVALID_USER_DATA
  }),
  bankName: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_USER_DATA,
    'string.empty': errorCodes.INVALID_USER_DATA
  }),
  bankCode: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_USER_DATA,
    'string.empty': errorCodes.INVALID_USER_DATA
  }),
  branchCode: Joi.string(),
  swiftCode: Joi.string()
});

// Commission structure schema
const commissionStructureSchema = Joi.object({
  type: Joi.string().valid(...Object.values(CommissionType)).required().messages({
    'any.only': errorCodes.INVALID_STATUS,
    'any.required': errorCodes.INVALID_USER_DATA
  }),
  value: Joi.number().positive().required().messages({
    'number.positive': errorCodes.INVALID_AMOUNT,
    'any.required': errorCodes.INVALID_USER_DATA
  }),
  minAmount: Joi.number().min(0),
  maxAmount: Joi.number().greater(Joi.ref('minAmount')).messages({
    'number.greater': errorCodes.INVALID_AMOUNT
  })
});

// Create affiliate schema
export const createAffiliateSchema = Joi.object({
  userId: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_USER_DATA,
    'string.empty': errorCodes.INVALID_USER_DATA
  }),
  companyName: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_USER_DATA,
    'string.empty': errorCodes.INVALID_USER_DATA
  }),
  website: Joi.string().uri().messages({
    'string.uri': errorCodes.VALIDATION_ERROR
  }),
  description: Joi.string().max(500),
  bankAccount: bankAccountSchema.required().messages({
    'any.required': errorCodes.INVALID_USER_DATA,
    'object.base': errorCodes.INVALID_USER_DATA
  }),
  commissionStructure: commissionStructureSchema.required().messages({
    'any.required': errorCodes.INVALID_USER_DATA,
    'object.base': errorCodes.INVALID_USER_DATA
  }),
  referralCode: Joi.string().pattern(/^[A-Z0-9]{6,10}$/).required().messages({
    'string.pattern.base': errorCodes.INVALID_REFERRAL_CODE,
    'any.required': errorCodes.INVALID_REFERRAL_CODE
  }),
  documents: Joi.array().items(
    Joi.object({
      type: Joi.string().required(),
      url: Joi.string().uri().required(),
      verified: Joi.boolean().default(false)
    })
  )
});

// Update affiliate schema
export const updateAffiliateSchema = Joi.object({
  companyName: Joi.string(),
  website: Joi.string().uri(),
  description: Joi.string().max(500),
  bankAccount: bankAccountSchema,
  commissionStructure: commissionStructureSchema,
  status: Joi.string().valid(...Object.values(AffiliateStatus)).messages({
    'any.only': errorCodes.INVALID_STATUS
  }),
  documents: Joi.array().items(
    Joi.object({
      type: Joi.string().required(),
      url: Joi.string().uri().required(),
      verified: Joi.boolean()
    })
  )
}).min(1).messages({
  'object.min': errorCodes.VALIDATION_ERROR
});

// Create payout request schema
export const createPayoutRequestSchema = Joi.object({
  affiliateId: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_USER_DATA,
    'string.empty': errorCodes.INVALID_USER_DATA
  }),
  amount: Joi.number().positive().required().messages({
    'number.positive': errorCodes.INVALID_AMOUNT,
    'any.required': errorCodes.INVALID_USER_DATA
  }),
  bankAccount: bankAccountSchema.required().messages({
    'any.required': errorCodes.INVALID_USER_DATA,
    'object.base': errorCodes.INVALID_USER_DATA
  }),
  notes: Joi.string().max(500)
});

// Update payout status schema
export const updatePayoutStatusSchema = Joi.object({
  status: Joi.string().valid(...Object.values(PayoutStatus)).required().messages({
    'any.only': errorCodes.INVALID_STATUS,
    'any.required': errorCodes.INVALID_USER_DATA
  }),
  transactionId: Joi.string().when('status', {
    is: PayoutStatus.COMPLETED,
    then: Joi.required(),
    otherwise: Joi.optional()
  }).messages({
    'any.required': errorCodes.INVALID_USER_DATA
  }),
  notes: Joi.string().max(500)
});

// Search affiliates schema
export const searchAffiliatesSchema = Joi.object({
  query: Joi.string(),
  status: Joi.string().valid(...Object.values(AffiliateStatus)).messages({
    'any.only': errorCodes.INVALID_STATUS
  }),
  minEarnings: Joi.number().min(0),
  maxEarnings: Joi.number().min(Joi.ref('minEarnings')).messages({
    'number.min': errorCodes.INVALID_AMOUNT
  }),
  startDate: Joi.date(),
  endDate: Joi.date().min(Joi.ref('startDate')).messages({
    'date.min': errorCodes.VALIDATION_ERROR
  }),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(10),
  sortBy: Joi.string().valid('createdAt', 'earnings', 'referrals').default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc')
});

// Affiliate statistics schema
export const affiliateStatsSchema = Joi.object({
  affiliateId: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_USER_DATA,
    'string.empty': errorCodes.INVALID_USER_DATA
  }),
  startDate: Joi.date().required().messages({
    'any.required': errorCodes.INVALID_USER_DATA,
    'date.base': errorCodes.VALIDATION_ERROR
  }),
  endDate: Joi.date().min(Joi.ref('startDate')).required().messages({
    'date.min': errorCodes.VALIDATION_ERROR,
    'any.required': errorCodes.INVALID_USER_DATA
  }),
  groupBy: Joi.string().valid('day', 'week', 'month').default('day')
});
