import Joi from 'joi';
import { BillingStatus } from '../models/billing';
import { SubscriptionType } from '../models/subscription/subscriptionPlan';

// Schéma pour la création d'une facture
export const createBillSchema = Joi.object({
  userId: Joi.string().required(),
  orderId: Joi.string().required(),
  amount: Joi.number().min(0).required(),
  tax: Joi.number().min(0),
  discount: Joi.number().min(0),
  pointsEarned: Joi.number().min(0),
  pointsUsed: Joi.number().min(0),
  status: Joi.string().valid(...Object.values(BillingStatus)).required(),
  dueDate: Joi.date().min('now').required(),
  paymentMethod: Joi.string().required(),
  notes: Joi.string().allow('')
});

// Schéma pour la mise à jour d'une facture
export const updateBillSchema = Joi.object({
  status: Joi.string().valid(...Object.values(BillingStatus)),
  paymentMethod: Joi.string(),
  notes: Joi.string().allow(''),
  pointsUsed: Joi.number().min(0)
}).min(1);

// Schéma pour la création d'un abonnement
export const createSubscriptionSchema = Joi.object({
  userId: Joi.string().required(),
  type: Joi.string().valid(...Object.values(SubscriptionType)).required(),
  startDate: Joi.date().min('now').required(),
  endDate: Joi.date().min(Joi.ref('startDate')).required(),
  price: Joi.number().min(0).required(),
  features: Joi.array().items(Joi.string()).required(),
  autoRenew: Joi.boolean().default(false),
  paymentMethod: Joi.string().required()
});

// Schéma pour la mise à jour d'un abonnement
export const updateSubscriptionSchema = Joi.object({
  type: Joi.string().valid(...Object.values(SubscriptionType)),
  endDate: Joi.date(),
  autoRenew: Joi.boolean(),
  paymentMethod: Joi.string()
}).min(1);

// Schéma pour les opérations de points de fidélité
export const loyaltyPointsSchema = Joi.object({
  userId: Joi.string().required(),
  points: Joi.number().required(),
  operation: Joi.string().valid('add', 'subtract', 'redeem').required(),
  reason: Joi.string().required()
});

// Schéma pour la recherche de factures
export const searchBillsSchema = Joi.object({
  userId: Joi.string(),
  status: Joi.string().valid(...Object.values(BillingStatus)),
  startDate: Joi.date(),
  endDate: Joi.date().min(Joi.ref('startDate')),
  minAmount: Joi.number().min(0),
  maxAmount: Joi.number().min(Joi.ref('minAmount')),
  page: Joi.number().min(1).default(1),
  limit: Joi.number().min(1).max(100).default(10)
});

// Schéma pour les statistiques de facturation
export const billingStatsSchema = Joi.object({
  startDate: Joi.date().required(),
  endDate: Joi.date().min(Joi.ref('startDate')).required(),
  userId: Joi.string(),
  includeSubscriptions: Joi.boolean().default(true),
  includeLoyaltyPoints: Joi.boolean().default(true)
});
