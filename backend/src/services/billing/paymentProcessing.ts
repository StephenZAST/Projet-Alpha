import { createClient } from '@supabase/supabase-js';
import { Bill, BillStatus, PaymentMethod, RefundStatus, PaymentStatus } from '../../models/bill';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const billsTable = 'bills';

export async function payBill(billId: string, paymentMethod: PaymentMethod, amountPaid: number, userId: string): Promise<Bill> {
  try {
    const currentBill = await getBill(billId);

    if (!currentBill) {
      throw new AppError(404, 'Bill not found', errorCodes.NOT_FOUND);
    }

    const updatedBill = {
      paymentMethod,
      paymentStatus: PaymentStatus.COMPLETED,
      paymentDate: new Date().toISOString(),
      status: BillStatus.PAID,
      total: currentBill.total - amountPaid,
      notes: `Payment of ${amountPaid} ${currentBill.currency} made by ${userId}`
    };

    const { data, error } = await supabase.from(billsTable).update(updatedBill).eq('id', billId).select().single();

    if (error) {
      throw new AppError(500, 'Failed to pay bill', errorCodes.DATABASE_ERROR);
    }

    return data as Bill;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to pay bill', errorCodes.DATABASE_ERROR);
  }
}

export async function refundBill(billId: string, refundReason: string, userId: string, refundAmount?: number): Promise<Bill> {
  try {
    const currentBill = await getBill(billId);

    if (!currentBill) {
      throw new AppError(404, 'Bill not found', errorCodes.NOT_FOUND);
    }

    const updatedBill = {
      refundStatus: RefundStatus.COMPLETED,
      refundDate: new Date().toISOString(),
      refundAmount: refundAmount || currentBill.total,
      notes: `Refund of ${refundAmount || currentBill.total} ${currentBill.currency} made by ${userId} for reason: ${refundReason}`
    };

    const { data, error } = await supabase.from(billsTable).update(updatedBill).eq('id', billId).select().single();

    if (error) {
      throw new AppError(500, 'Failed to refund bill', errorCodes.DATABASE_ERROR);
    }

    return data as Bill;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to refund bill', errorCodes.DATABASE_ERROR);
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
