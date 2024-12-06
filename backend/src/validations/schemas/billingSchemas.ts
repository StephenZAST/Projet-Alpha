import Joi from 'joi';
import { BillingStatus, PaymentMethod, CurrencyCode } from '../../models/billing';

// Base price schema
const priceSchema = Joi.object({
  amount: Joi.number().positive().required().messages({
    'number.positive': 'Le montant doit être positif',
    'any.required': 'Le montant est requis'
  }),
  currency: Joi.string().valid(...Object.values(CurrencyCode)).required().messages({
    'any.only': 'Devise invalide',
    'any.required': 'La devise est requise'
  })
});

// Invoice item schema
export const invoiceItemSchema = Joi.object({
  description: Joi.string().required().messages({
    'any.required': 'La description est requise'
  }),
  quantity: Joi.number().integer().min(1).required().messages({
    'number.integer': 'La quantité doit être un nombre entier',
    'number.min': 'La quantité doit être supérieure à 0',
    'any.required': 'La quantité est requise'
  }),
  unitPrice: priceSchema.required().messages({
    'any.required': 'Le prix unitaire est requis'
  }),
  taxRate: Joi.number().min(0).max(100).default(0).messages({
    'number.min': 'Le taux de taxe doit être entre 0 et 100',
    'number.max': 'Le taux de taxe doit être entre 0 et 100'
  }),
  discountRate: Joi.number().min(0).max(100).default(0).messages({
    'number.min': 'Le taux de remise doit être entre 0 et 100',
    'number.max': 'Le taux de remise doit être entre 0 et 100'
  })
});

// Create invoice schema
export const createInvoiceSchema = Joi.object({
  customerId: Joi.string().required().messages({
    'any.required': 'L\'ID du client est requis'
  }),
  orderId: Joi.string().required().messages({
    'any.required': 'L\'ID de la commande est requis'
  }),
  items: Joi.array().items(invoiceItemSchema).min(1).required().messages({
    'array.min': 'Au moins un article est requis',
    'any.required': 'Les articles sont requis'
  }),
  dueDate: Joi.date().greater('now').required().messages({
    'date.greater': 'La date d\'échéance doit être dans le futur',
    'any.required': 'La date d\'échéance est requise'
  }),
  paymentMethod: Joi.string().valid(...Object.values(PaymentMethod)).required().messages({
    'any.only': 'Méthode de paiement invalide',
    'any.required': 'La méthode de paiement est requise'
  }),
  notes: Joi.string().max(500)
});

// Update invoice schema
export const updateInvoiceSchema = Joi.object({
  status: Joi.string().valid(...Object.values(BillingStatus)).required().messages({
    'any.only': 'Statut invalide',
    'any.required': 'Le statut est requis'
  }),
  paymentMethod: Joi.string().valid(...Object.values(PaymentMethod)),
  notes: Joi.string().max(500),
  paidAt: Joi.date().when('status', {
    is: BillingStatus.PAID,
    then: Joi.required(),
    otherwise: Joi.forbidden()
  }).messages({
    'any.required': 'La date de paiement est requise pour le statut PAID',
    'any.unknown': 'La date de paiement n\'est pas autorisée pour ce statut'
  })
});

// Search invoices schema
export const searchInvoicesSchema = Joi.object({
  customerId: Joi.string(),
  orderId: Joi.string(),
  status: Joi.string().valid(...Object.values(BillingStatus)),
  startDate: Joi.date(),
  endDate: Joi.date().min(Joi.ref('startDate')).messages({
    'date.min': 'La date de fin doit être après la date de début'
  }),
  minAmount: Joi.number().min(0),
  maxAmount: Joi.number().min(Joi.ref('minAmount')).messages({
    'number.min': 'Le montant maximum doit être supérieur au montant minimum'
  }),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(10),
  sortBy: Joi.string().valid('createdAt', 'dueDate', 'amount').default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc')
});

// Payment schema
export const createPaymentSchema = Joi.object({
  invoiceId: Joi.string().required().messages({
    'any.required': 'L\'ID de la facture est requis'
  }),
  amount: Joi.number().positive().required().messages({
    'number.positive': 'Le montant doit être positif',
    'any.required': 'Le montant est requis'
  }),
  paymentMethod: Joi.string().valid(...Object.values(PaymentMethod)).required().messages({
    'any.only': 'Méthode de paiement invalide',
    'any.required': 'La méthode de paiement est requise'
  }),
  transactionId: Joi.string().when('paymentMethod', {
    is: Joi.string().valid(PaymentMethod.CARD, PaymentMethod.MOBILE_MONEY),
    then: Joi.required(),
    otherwise: Joi.optional()
  }).messages({
    'any.required': 'L\'ID de transaction est requis pour ce mode de paiement'
  }),
  notes: Joi.string().max(500)
});
