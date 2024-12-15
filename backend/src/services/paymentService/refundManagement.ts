import { createClient } from '@supabase/supabase-js';
import { Refund, PaymentStatus, RefundReason, Currency } from '../../models/payment';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const refundsTable = 'refunds';
const paymentsTable = 'payments';

export async function getRefund(id: string): Promise<Refund | null> {
  try {
    const { data, error } = await supabase.from(refundsTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch refund', errorCodes.DATABASE_ERROR);
    }

    return data as Refund;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch refund', errorCodes.DATABASE_ERROR);
  }
}

export async function createRefund(refundData: Refund): Promise<Refund> {
  try {
    const { data, error } = await supabase.from(refundsTable).insert([refundData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create refund', errorCodes.DATABASE_ERROR);
    }

    const { error: updateError } = await supabase.from(paymentsTable).update({ status: 'REFUNDED' }).eq('id', refundData.paymentId);

    if (updateError) {
      throw new AppError(500, 'Failed to update payment status', errorCodes.DATABASE_ERROR);
    }

    return data as Refund;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to create refund', errorCodes.DATABASE_ERROR);
  }
}

export async function updateRefund(id: string, refundData: Partial<Refund>): Promise<Refund> {
  try {
    const currentRefund = await getRefund(id);

    if (!currentRefund) {
      throw new AppError(404, 'Refund not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(refundsTable).update(refundData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update refund', errorCodes.DATABASE_ERROR);
    }

    return data as Refund;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update refund', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteRefund(id: string): Promise<void> {
  try {
    const refund = await getRefund(id);

    if (!refund) {
      throw new AppError(404, 'Refund not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(refundsTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete refund', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to delete refund', errorCodes.DATABASE_ERROR);
  }
}
