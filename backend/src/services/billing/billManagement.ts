import { createClient } from '@supabase/supabase-js';
import { Bill, BillItem, BillStatus, PaymentStatus, RefundStatus } from '../../models/bill';
import { AppError, errorCodes } from '../../utils/errors';

import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_SERVICE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl as string, supabaseKey);

const billsTable = 'bills';

export async function getBill(id: string): Promise<Bill | null> {
  try {
    const { data, error } = await supabase.from(billsTable).select('*').eq('id', id).single();

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

export async function createBill(billData: Bill): Promise<Bill> {
  try {
    const { data, error } = await supabase.from(billsTable).insert([billData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create bill', errorCodes.DATABASE_ERROR);
    }

    return data as Bill;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to create bill', errorCodes.DATABASE_ERROR);
  }
}

export async function updateBill(id: string, billData: Partial<Bill>): Promise<Bill> {
  try {
    const currentBill = await getBill(id);

    if (!currentBill) {
      throw new AppError(404, 'Bill not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(billsTable).update(billData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update bill', errorCodes.DATABASE_ERROR);
    }

    return data as Bill;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update bill', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteBill(id: string): Promise<void> {
  try {
    const bill = await getBill(id);

    if (!bill) {
      throw new AppError(404, 'Bill not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(billsTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete bill', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to delete bill', errorCodes.DATABASE_ERROR);
  }
}
