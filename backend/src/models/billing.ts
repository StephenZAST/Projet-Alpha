import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';
import { Bill, BillItem, SubscriptionBillingInfo } from './bill';
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

// Function to get bill data
export async function getBill(id: string): Promise<Bill | null> {
  const { data, error } = await supabase.from(billsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch bill', 'INTERNAL_SERVER_ERROR');
  }

  return data as Bill;
}

// Function to create bill
export async function createBill(billData: Bill): Promise<Bill> {
  const { data, error } = await supabase.from(billsTable).insert([billData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create bill', 'INTERNAL_SERVER_ERROR');
  }

  return data as Bill;
}

// Function to update bill
export async function updateBill(id: string, billData: Partial<Bill>): Promise<Bill> {
  const currentBill = await getBill(id);

  if (!currentBill) {
    throw new AppError(404, 'Bill not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(billsTable).update(billData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update bill', 'INTERNAL_SERVER_ERROR');
  }

  return data as Bill;
}

// Function to delete bill
export async function deleteBill(id: string): Promise<void> {
  const bill = await getBill(id);

  if (!bill) {
    throw new AppError(404, 'Bill not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(billsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete bill', 'INTERNAL_SERVER_ERROR');
  }
}

// Function to get loyalty transaction data
export async function getLoyaltyTransaction(id: string): Promise<LoyaltyTransaction | null> {
  const { data, error } = await supabase.from(loyaltyTransactionsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch loyalty transaction', 'INTERNAL_SERVER_ERROR');
  }

  return data as LoyaltyTransaction;
}

// Function to create loyalty transaction
export async function createLoyaltyTransaction(transactionData: LoyaltyTransaction): Promise<LoyaltyTransaction> {
  const { data, error } = await supabase.from(loyaltyTransactionsTable).insert([transactionData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create loyalty transaction', 'INTERNAL_SERVER_ERROR');
  }

  return data as LoyaltyTransaction;
}

// Function to update loyalty transaction
export async function updateLoyaltyTransaction(id: string, transactionData: Partial<LoyaltyTransaction>): Promise<LoyaltyTransaction> {
  const currentTransaction = await getLoyaltyTransaction(id);

  if (!currentTransaction) {
    throw new AppError(404, 'Loyalty transaction not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(loyaltyTransactionsTable).update(transactionData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update loyalty transaction', 'INTERNAL_SERVER_ERROR');
  }

  return data as LoyaltyTransaction;
}

// Function to delete loyalty transaction
export async function deleteLoyaltyTransaction(id: string): Promise<void> {
  const transaction = await getLoyaltyTransaction(id);

  if (!transaction) {
    throw new AppError(404, 'Loyalty transaction not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(loyaltyTransactionsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete loyalty transaction', 'INTERNAL_SERVER_ERROR');
  }
}

// Function to get offer data
export async function getOffer(id: string): Promise<Offer | null> {
  const { data, error } = await supabase.from(offersTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch offer', 'INTERNAL_SERVER_ERROR');
  }

  return data as Offer;
}

// Function to create offer
export async function createOffer(offerData: Offer): Promise<Offer> {
  const { data, error } = await supabase.from(offersTable).insert([offerData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create offer', 'INTERNAL_SERVER_ERROR');
  }

  return data as Offer;
}

// Function to update offer
export async function updateOffer(id: string, offerData: Partial<Offer>): Promise<Offer> {
  const currentOffer = await getOffer(id);

  if (!currentOffer) {
    throw new AppError(404, 'Offer not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(offersTable).update(offerData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update offer', 'INTERNAL_SERVER_ERROR');
  }

  return data as Offer;
}

// Function to delete offer
export async function deleteOffer(id: string): Promise<void> {
  const offer = await getOffer(id);

  if (!offer) {
    throw new AppError(404, 'Offer not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(offersTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete offer', 'INTERNAL_SERVER_ERROR');
  }
}
