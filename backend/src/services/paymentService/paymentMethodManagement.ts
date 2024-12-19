import { createClient } from '@supabase/supabase-js';
import { PaymentMethod, PaymentMethodType, PaymentStatus, Currency } from '../../models/payment';
import { AppError, errorCodes } from '../../utils/errors';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL or SUPABASE_SERVICE_KEY environment variables not set.');
}

const supabase = createClient(supabaseUrl as string, supabaseKey as string);

const paymentMethodsTable = 'paymentMethods';

export async function getPaymentMethods(userId: string): Promise<PaymentMethod[]> {
  try {
    const { data, error } = await supabase
      .from(paymentMethodsTable)
      .select('*')
      .eq('userId', userId);

    if (error) {
      throw new AppError(500, 'Failed to fetch payment methods', errorCodes.DATABASE_ERROR);
    }

    return data as PaymentMethod[];
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch payment methods', errorCodes.DATABASE_ERROR);
  }
}

export async function addPaymentMethod(userId: string, data: {
  type: PaymentMethodType;
  token: string;
  isDefault?: boolean;
}): Promise<PaymentMethod> {
  try {
    const paymentMethodData: Omit<PaymentMethod, 'id'> = {
      userId,
      type: data.type,
      token: data.token,
      isDefault: data.isDefault || false,
      createdAt: new Date().toISOString(),
    };

    const { data: newMethod, error: addError } = await supabase.from(paymentMethodsTable).insert([paymentMethodData]).select().single();

    if (addError) {
      throw new AppError(500, 'Failed to add payment method', errorCodes.DATABASE_ERROR);
    }

    if (data.isDefault) {
      await updateOtherPaymentMethodsDefault(userId, newMethod.id);
    }

    return {
      id: newMethod.id,
      ...paymentMethodData,
    };
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to add payment method', errorCodes.DATABASE_ERROR);
  }
}

async function updateOtherPaymentMethodsDefault(userId: string, excludeId: string) {
  try {
    const { data: methods, error: fetchError } = await supabase
      .from(paymentMethodsTable)
      .select('*')
      .eq('userId', userId)
      .eq('isDefault', true);

    if (fetchError) {
      throw new AppError(500, 'Failed to fetch payment methods', errorCodes.DATABASE_ERROR);
    }

    const updatePromises = methods?.map((method: { id: string }) => {
      if (method.id !== excludeId) {
        return supabase.from(paymentMethodsTable).update({ isDefault: false }).eq('id', method.id);
      }
    });

    await Promise.all(updatePromises || []);
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update payment methods', errorCodes.DATABASE_ERROR);
  }
}

export async function removePaymentMethod(userId: string, paymentMethodId: string): Promise<void> {
  try {
    const { data: method, error: fetchError } = await supabase
      .from(paymentMethodsTable)
      .select('*')
      .eq('id', paymentMethodId)
      .single();

    if (fetchError) {
      throw new AppError(404, 'Payment method not found', errorCodes.NOT_FOUND);
    }

    if (method?.userId !== userId) {
      throw new AppError(403, 'Unauthorized', errorCodes.UNAUTHORIZED);
    }

    const { error: deleteError } = await supabase.from(paymentMethodsTable).delete().eq('id', paymentMethodId);

    if (deleteError) {
      throw new AppError(500, 'Failed to delete payment method', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to delete payment method', errorCodes.DATABASE_ERROR);
  }
}

export async function setDefaultPaymentMethod(userId: string, paymentMethodId: string): Promise<void> {
  try {
    const { data: method, error: fetchError } = await supabase
      .from(paymentMethodsTable)
      .select('*')
      .eq('id', paymentMethodId)
      .single();

    if (fetchError) {
      throw new AppError(404, 'Payment method not found', errorCodes.NOT_FOUND);
    }

    if (method?.userId !== userId) {
      throw new AppError(403, 'Unauthorized', errorCodes.UNAUTHORIZED);
    }

    await updateOtherPaymentMethodsDefault(userId, paymentMethodId);
    const { error: updateError } = await supabase.from(paymentMethodsTable).update({ isDefault: true }).eq('id', paymentMethodId);

    if (updateError) {
      throw new AppError(500, 'Failed to set default payment method', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to set default payment method', errorCodes.DATABASE_ERROR);
  }
}
