import { createClient } from '@supabase/supabase-js';
import { SubscriptionBilling } from '../../models/subscription';
import { AppError, errorCodes } from '../../utils/errors';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL or SUPABASE_SERVICE_KEY environment variables not set.');
}

const supabase = createClient(supabaseUrl as string, supabaseKey as string);

const subscriptionBillingsTable = 'subscriptionBillings';

export async function getSubscriptionBilling(id: string): Promise<SubscriptionBilling | null> {
  try {
    const { data, error } = await supabase.from(subscriptionBillingsTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch subscription billing', errorCodes.DATABASE_ERROR);
    }

    return data as SubscriptionBilling;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch subscription billing', errorCodes.DATABASE_ERROR);
  }
}

export async function createSubscriptionBilling(billingData: SubscriptionBilling): Promise<SubscriptionBilling> {
  try {
    const { data, error } = await supabase.from(subscriptionBillingsTable).insert([billingData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create subscription billing', errorCodes.DATABASE_ERROR);
    }

    return data as SubscriptionBilling;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to create subscription billing', errorCodes.DATABASE_ERROR);
  }
}

export async function updateSubscriptionBilling(id: string, billingData: Partial<SubscriptionBilling>): Promise<SubscriptionBilling> {
  try {
    const currentBilling = await getSubscriptionBilling(id);

    if (!currentBilling) {
      throw new AppError(404, 'Subscription billing not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(subscriptionBillingsTable).update(billingData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update subscription billing', errorCodes.DATABASE_ERROR);
    }

    return data as SubscriptionBilling;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update subscription billing', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteSubscriptionBilling(id: string): Promise<void> {
  try {
    const billing = await getSubscriptionBilling(id);

    if (!billing) {
      throw new AppError(404, 'Subscription billing not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(subscriptionBillingsTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete subscription billing', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to delete subscription billing', errorCodes.DATABASE_ERROR);
  }
}
