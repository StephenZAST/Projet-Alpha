import { createClient } from '@supabase/supabase-js';
import { Bill, BillStatus } from '../../models/bill';
import { AppError, errorCodes } from '../../utils/errors';
import { LoyaltyTransaction } from '../../models/loyalty/loyaltyTransaction';
import { Offer } from '../../models/offer';
import { getBill } from './billManagement';

import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_SERVICE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl as string, supabaseKey as string);

const billsTable = 'bills';
const loyaltyTransactionsTable = 'loyaltyTransactions';
const offersTable = 'offers';

export async function applyLoyaltyPointsToBill(billId: string, userId: string, rewardId: string): Promise<Bill> {
  try {
    const currentBill = await getBill(billId);

    if (!currentBill) {
      throw new AppError(404, 'Bill not found', errorCodes.NOT_FOUND);
    }

    // Implementation for applying loyalty points to a bill
    const updatedBill = {
      loyaltyPointsUsed: 100, // Example value, replace with actual logic
      total: currentBill.total - 100, // Example value, replace with actual logic
      notes: `Loyalty points applied by ${userId}`
    };

    const { data, error } = await supabase.from(billsTable).update(updatedBill).eq('id', billId).select().single();

    if (error) {
      throw new AppError(500, 'Failed to apply loyalty points to bill', errorCodes.DATABASE_ERROR);
    }

    return data as Bill;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to apply loyalty points to bill', errorCodes.DATABASE_ERROR);
  }
}

export async function applySubscriptionDiscountToBill(billId: string, userId: string, planId: string): Promise<Bill> {
  try {
    const currentBill = await getBill(billId);

    if (!currentBill) {
      throw new AppError(404, 'Bill not found', errorCodes.NOT_FOUND);
    }

    // Implementation for applying subscription discount to a bill
    const updatedBill = {
      discount: 100, // Example value, replace with actual logic
      total: currentBill.total - 100, // Example value, replace with actual logic
      notes: `Subscription discount applied by ${userId}`
    };

    const { data, error } = await supabase.from(billsTable).update(updatedBill).eq('id', billId).select().single();

    if (error) {
      throw new AppError(500, 'Failed to apply subscription discount to bill', errorCodes.DATABASE_ERROR);
    }

    return data as Bill;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to apply subscription discount to bill', errorCodes.DATABASE_ERROR);
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
