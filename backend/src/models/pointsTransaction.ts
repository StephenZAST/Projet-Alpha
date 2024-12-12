import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export interface PointsTransaction {
  id: string;
  userId: string;
  amount: number;
  type: 'EARNED' | 'REDEEMED' | 'EXPIRED' | 'ADJUSTED';
  source: 'PURCHASE' | 'REFERRAL' | 'PROMOTION' | 'MANUAL' | 'SYSTEM';
  description: string;
  metadata?: {
    orderId?: string;
    promotionId?: string;
    referralId?: string;
    adminId?: string;
  };
  timestamp: string;
}

// Use Supabase to store points transaction data
const pointsTransactionsTable = 'pointsTransactions';

// Function to get points transaction data
export async function getPointsTransaction(id: string): Promise<PointsTransaction | null> {
  const { data, error } = await supabase.from(pointsTransactionsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch points transaction', 'INTERNAL_SERVER_ERROR');
  }

  return data as PointsTransaction;
}

// Function to create points transaction
export async function createPointsTransaction(transactionData: PointsTransaction): Promise<PointsTransaction> {
  const { data, error } = await supabase.from(pointsTransactionsTable).insert([transactionData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create points transaction', 'INTERNAL_SERVER_ERROR');
  }

  return data as PointsTransaction;
}

// Function to update points transaction
export async function updatePointsTransaction(id: string, transactionData: Partial<PointsTransaction>): Promise<PointsTransaction> {
  const currentTransaction = await getPointsTransaction(id);

  if (!currentTransaction) {
    throw new AppError(404, 'Points transaction not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(pointsTransactionsTable).update(transactionData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update points transaction', 'INTERNAL_SERVER_ERROR');
  }

  return data as PointsTransaction;
}

// Function to delete points transaction
export async function deletePointsTransaction(id: string): Promise<void> {
  const transaction = await getPointsTransaction(id);

  if (!transaction) {
    throw new AppError(404, 'Points transaction not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(pointsTransactionsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete points transaction', 'INTERNAL_SERVER_ERROR');
  }
}
