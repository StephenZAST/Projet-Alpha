import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';
import { Bill, BillItem } from './bill';
import { LoyaltyTransaction } from './loyalty/loyaltyTransaction';
import { Offer } from './offer';

export enum BillingStatus {
  PENDING = 'PENDING',
  PAID = 'PAID',
  OVERDUE = 'OVERDUE',
  CANCELLED = 'CANCELLED',
  REFUNDED = 'REFUNDED',
}

export enum PaymentMethod {
  CASH = 'CASH',
  CARD = 'CARD',
  MOBILE_MONEY = 'MOBILE_MONEY',
  BANK_TRANSFER = 'BANK_TRANSFER',
}

export enum CurrencyCode {
  USD = 'USD',
  EUR = 'EUR',
  GBP = 'GBP',
}

// Use Supabase to store billing data
const billsTable = 'bills';
const loyaltyTransactionsTable = 'loyaltyTransactions';
const offersTable = 'offers';
