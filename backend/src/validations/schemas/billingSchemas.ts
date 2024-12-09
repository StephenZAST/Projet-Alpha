import Joi from 'joi';
import { BillingStatus, PaymentMethod, CurrencyCode } from '../../models/billing';
import { errorCodes } from '../../utils/errors';

// Base price schema
const priceSchema = Joi.object({
  amount: Joi.number().positive().required().messages({
    'number.positive': errorCodes.INVALID_AMOUNT,
    'any.required': errorCodes.INVALID_AMOUNT
  }),
  currency: Joi.string().valid(...Object.values(CurrencyCode)).required().messages({
    'any.only': errorCodes.INVALID_AMOUNT,
    'any.required': errorCodes.INVALID_AMOUNT
  })
});

// Invoice item schema
export const invoiceItemSchema = Joi.object({
  description: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_INVOICE_ITEM
  }),
  quantity: Joi.number().integer().min(1).required().messages({
    'number.integer': errorCodes.INVALID_INVOICE_ITEM,
    'number.min': errorCodes.INVALID_INVOICE_ITEM,
    'any.required': errorCodes.INVALID_INVOICE_ITEM
  }),
  unitPrice: priceSchema.required().messages({
    'any.required': errorCodes.INVALID_INVOICE_ITEM
  }),
  taxRate: Joi.number().min(0).max(100).default(0).messages({
    'number.min': errorCodes.INVALID_INVOICE_ITEM,
    'number.max': errorCodes.INVALID_INVOICE_ITEM
  }),
  discountRate: Joi.number().min(0).max(100).default(0).messages({
    'number.min': errorCodes.INVALID_INVOICE_ITEM,
    'number.max': errorCodes.INVALID_INVOICE_ITEM
  })
});

// Create invoice schema
export const createInvoiceSchema = Joi.object({
  customerId: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_CUSTOMER_DATA
  }),
  orderId: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_ORDER_DATA
  }),
  items: Joi.array().items(invoiceItemSchema).min(1).required().messages({
    'array.min': errorCodes.INVALID_INVOICE_ITEMS,
    'any.required': errorCodes.INVALID_INVOICE_ITEMS
  }),
  dueDate: Joi.date().greater('now').required().messages({
    'date.greater': errorCodes.INVALID_DUE_DATE,
    'any.required': errorCodes.INVALID_DUE_DATE
  }),
  paymentMethod: Joi.string().valid(...Object.values(PaymentMethod)).required().messages({
    'any.only': errorCodes.PAYMENT_PROCESSING_FAILED,
    'any.required': errorCodes.PAYMENT_PROCESSING_FAILED
  }),
  notes: Joi.string().max(500).messages({
    'string.max': errorCodes.INVALID_NOTES
  })
});

// Update invoice schema
export const updateInvoiceSchema = Joi.object({
  status: Joi.string().valid(...Object.values(BillingStatus)).required().messages({
    'any.only': errorCodes.INVALID_STATUS,
    'any.required': errorCodes.INVALID_STATUS
  }),
  paymentMethod: Joi.string().valid(...Object.values(PaymentMethod)).messages({
    'any.only': errorCodes.PAYMENT_PROCESSING_FAILED
  }),
  notes: Joi.string().max(500).messages({
    'string.max': errorCodes.INVALID_NOTES
  }),
  paidAt: Joi.date().when('status', {
    is: BillingStatus.PAID,
    then: Joi.required(),
    otherwise: Joi.forbidden()
  }).messages({
    'any.required': errorCodes.INVALID_PAID_DATE,
    'any.unknown': errorCodes.INVALID_PAID_DATE
  })
});

// Search invoices schema
export const searchInvoicesSchema = Joi.object({
  customerId: Joi.string(),
  orderId: Joi.string(),
  status: Joi.string().valid(...Object.values(BillingStatus)).messages({
    'any.only': errorCodes.INVALID_STATUS
  }),
  startDate: Joi.date(),
  endDate: Joi.date().min(Joi.ref('startDate')).messages({
    'date.min': errorCodes.INVALID_DATE_RANGE
  }),
  minAmount: Joi.number().min(0).messages({
    'number.min': errorCodes.INVALID_AMOUNT
  }),
  maxAmount: Joi.number().min(Joi.ref('minAmount')).messages({
    'number.min': errorCodes.INVALID_AMOUNT
  }),
  page: Joi.number().integer().min(1).default(1).messages({
    'number.integer': errorCodes.INVALID_PAGE_NUMBER,
    'number.min': errorCodes.INVALID_PAGE_NUMBER
  }),
  limit: Joi.number().integer().min(1).max(100).default(10).messages({
    'number.integer': errorCodes.INVALID_PAGE_SIZE,
    'number.min': errorCodes.INVALID_PAGE_SIZE,
    'number.max': errorCodes.INVALID_PAGE_SIZE
  }),
  sortBy: Joi.string().valid('createdAt', 'dueDate', 'amount').default('createdAt').messages({
    'any.only': errorCodes.INVALID_SORT_BY
  }),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc').messages({
    'any.only': errorCodes.INVALID_SORT_ORDER
  })
});

// Payment schema
export const createPaymentSchema = Joi.object({
  invoiceId: Joi.string().required().messages({
    'any.required': errorCodes.INVALID_INVOICE_ID
  }),
  amount: Joi.number().positive().required().messages({
    'number.positive': errorCodes.INVALID_AMOUNT,
    'any.required': errorCodes.INVALID_AMOUNT
  }),
  paymentMethod: Joi.string().valid(...Object.values(PaymentMethod)).required().messages({
    'any.only': errorCodes.PAYMENT_PROCESSING_FAILED,
    'any.required': errorCodes.PAYMENT_PROCESSING_FAILED
  }),
  transactionId: Joi.string().when('paymentMethod', {
    is: Joi.string().valid(PaymentMethod.CARD, PaymentMethod.MOBILE_MONEY),
    then: Joi.required(),
    otherwise: Joi.optional()
  }).messages({
    'any.required': errorCodes.INVALID_TRANSACTION_ID
  }),
  notes: Joi.string().max(500).messages({
    'string.max': errorCodes.INVALID_NOTES
  })
});
