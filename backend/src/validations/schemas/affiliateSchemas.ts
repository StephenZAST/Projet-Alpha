import Joi from 'joi';
import { AffiliateStatus, CommissionType, PayoutStatus } from '../../models/affiliate';

// Bank account schema
const bankAccountSchema = Joi.object({
  accountName: Joi.string().required().messages({
    'any.required': 'Le nom du compte est requis'
  }),
  accountNumber: Joi.string().required().messages({
    'any.required': 'Le numéro de compte est requis'
  }),
  bankName: Joi.string().required().messages({
    'any.required': 'Le nom de la banque est requis'
  }),
  bankCode: Joi.string().required().messages({
    'any.required': 'Le code de la banque est requis'
  }),
  branchCode: Joi.string(),
  swiftCode: Joi.string()
});

// Commission structure schema
const commissionStructureSchema = Joi.object({
  type: Joi.string().valid(...Object.values(CommissionType)).required().messages({
    'any.only': 'Type de commission invalide',
    'any.required': 'Le type de commission est requis'
  }),
  value: Joi.number().positive().required().messages({
    'number.positive': 'La valeur doit être positive',
    'any.required': 'La valeur est requise'
  }),
  minAmount: Joi.number().min(0),
  maxAmount: Joi.number().greater(Joi.ref('minAmount')).messages({
    'number.greater': 'Le montant maximum doit être supérieur au montant minimum'
  })
});

// Create affiliate schema
export const createAffiliateSchema = Joi.object({
  userId: Joi.string().required().messages({
    'any.required': 'L\'ID de l\'utilisateur est requis'
  }),
  companyName: Joi.string().required().messages({
    'any.required': 'Le nom de l\'entreprise est requis'
  }),
  website: Joi.string().uri().messages({
    'string.uri': 'L\'URL du site web n\'est pas valide'
  }),
  description: Joi.string().max(500),
  bankAccount: bankAccountSchema.required(),
  commissionStructure: commissionStructureSchema.required(),
  referralCode: Joi.string().pattern(/^[A-Z0-9]{6,10}$/).required().messages({
    'string.pattern.base': 'Le code de parrainage doit contenir entre 6 et 10 caractères alphanumériques majuscules',
    'any.required': 'Le code de parrainage est requis'
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
  status: Joi.string().valid(...Object.values(AffiliateStatus)),
  documents: Joi.array().items(
    Joi.object({
      type: Joi.string().required(),
      url: Joi.string().uri().required(),
      verified: Joi.boolean()
    })
  )
}).min(1).messages({
  'object.min': 'Au moins un champ doit être fourni pour la mise à jour'
});

// Create payout request schema
export const createPayoutRequestSchema = Joi.object({
  affiliateId: Joi.string().required().messages({
    'any.required': 'L\'ID de l\'affilié est requis'
  }),
  amount: Joi.number().positive().required().messages({
    'number.positive': 'Le montant doit être positif',
    'any.required': 'Le montant est requis'
  }),
  bankAccount: bankAccountSchema.required(),
  notes: Joi.string().max(500)
});

// Update payout status schema
export const updatePayoutStatusSchema = Joi.object({
  status: Joi.string().valid(...Object.values(PayoutStatus)).required().messages({
    'any.only': 'Statut invalide',
    'any.required': 'Le statut est requis'
  }),
  transactionId: Joi.string().when('status', {
    is: PayoutStatus.COMPLETED,
    then: Joi.required(),
    otherwise: Joi.optional()
  }).messages({
    'any.required': 'L\'ID de transaction est requis pour le statut COMPLETED'
  }),
  notes: Joi.string().max(500)
});

// Search affiliates schema
export const searchAffiliatesSchema = Joi.object({
  query: Joi.string(),
  status: Joi.string().valid(...Object.values(AffiliateStatus)),
  minEarnings: Joi.number().min(0),
  maxEarnings: Joi.number().min(Joi.ref('minEarnings')).messages({
    'number.min': 'Les gains maximum doivent être supérieurs aux gains minimum'
  }),
  startDate: Joi.date(),
  endDate: Joi.date().min(Joi.ref('startDate')).messages({
    'date.min': 'La date de fin doit être après la date de début'
  }),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(10),
  sortBy: Joi.string().valid('createdAt', 'earnings', 'referrals').default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc')
});

// Affiliate statistics schema
export const affiliateStatsSchema = Joi.object({
  affiliateId: Joi.string().required().messages({
    'any.required': 'L\'ID de l\'affilié est requis'
  }),
  startDate: Joi.date().required().messages({
    'any.required': 'La date de début est requise'
  }),
  endDate: Joi.date().min(Joi.ref('startDate')).required().messages({
    'date.min': 'La date de fin doit être après la date de début',
    'any.required': 'La date de fin est requise'
  }),
  groupBy: Joi.string().valid('day', 'week', 'month').default('day')
});
