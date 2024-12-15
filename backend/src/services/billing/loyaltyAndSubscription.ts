import { createClient } from '@supabase/supabase-js';
import { Bill, BillStatus } from '../../models/bill';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const billsTable = 'bills';

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

async function getBill(billId: string): Promise<Bill | null> {
  try {
    const { data, error } = await supabase.from(billsTable).select('*').eq('id', billId).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch bill', errorCodes.DATABASE_ERROR);
    }

    return data as Bill;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch bill', errorCodes.DATABASE_ERROR);
  }
}
