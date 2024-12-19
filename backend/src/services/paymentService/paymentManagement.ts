import { createClient } from '@supabase/supabase-js';
import { Payment, PaymentMethodType, PaymentStatus, Currency } from '../../models/payment';
import { AppError, errorCodes } from '../../utils/errors';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL or SUPABASE_SERVICE_KEY environment variables not set.');
}

const supabase = createClient(supabaseUrl as string, supabaseKey as string);

const paymentsTable = 'payments';

export async function getPayment(id: string): Promise<Payment | null> {
  try {
    const { data, error } = await supabase.from(paymentsTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch payment', errorCodes.DATABASE_ERROR);
    }

    return data as Payment;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch payment', errorCodes.DATABASE_ERROR);
  }
}

export async function createPayment(paymentData: Payment): Promise<Payment> {
  try {
    const { data, error } = await supabase.from(paymentsTable).insert([paymentData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create payment', errorCodes.DATABASE_ERROR);
    }

    return data as Payment;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to create payment', errorCodes.DATABASE_ERROR);
  }
}

export async function updatePayment(id: string, paymentData: Partial<Payment>): Promise<Payment> {
  try {
    const currentPayment = await getPayment(id);

    if (!currentPayment) {
      throw new AppError(404, 'Payment not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(paymentsTable).update(paymentData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update payment', errorCodes.DATABASE_ERROR);
    }

    return data as Payment;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update payment', errorCodes.DATABASE_ERROR);
  }
}

export async function deletePayment(id: string): Promise<void> {
  try {
    const payment = await getPayment(id);

    if (!payment) {
      throw new AppError(404, 'Payment not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(paymentsTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete payment', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to delete payment', errorCodes.DATABASE_ERROR);
  }
}
