import { createClient } from '@supabase/supabase-js';
import { SubscriptionPause } from '../../models/subscription';
import { AppError, errorCodes } from '../../utils/errors';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL or SUPABASE_SERVICE_KEY environment variables not set.');
}

const supabase = createClient(supabaseUrl as string, supabaseKey as string);

const subscriptionPausesTable = 'subscriptionPauses';

export async function getSubscriptionPause(id: string): Promise<SubscriptionPause | null> {
  try {
    const { data, error } = await supabase.from(subscriptionPausesTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch subscription pause', errorCodes.DATABASE_ERROR);
    }

    return data as SubscriptionPause;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch subscription pause', errorCodes.DATABASE_ERROR);
  }
}

export async function createSubscriptionPause(pauseData: SubscriptionPause): Promise<SubscriptionPause> {
  try {
    const { data, error } = await supabase.from(subscriptionPausesTable).insert([pauseData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create subscription pause', errorCodes.DATABASE_ERROR);
    }

    return data as SubscriptionPause;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to create subscription pause', errorCodes.DATABASE_ERROR);
  }
}

export async function updateSubscriptionPause(id: string, pauseData: Partial<SubscriptionPause>): Promise<SubscriptionPause> {
  try {
    const currentPause = await getSubscriptionPause(id);

    if (!currentPause) {
      throw new AppError(404, 'Subscription pause not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(subscriptionPausesTable).update(pauseData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update subscription pause', errorCodes.DATABASE_ERROR);
    }

    return data as SubscriptionPause;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update subscription pause', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteSubscriptionPause(id: string): Promise<void> {
  try {
    const pause = await getSubscriptionPause(id);

    if (!pause) {
      throw new AppError(404, 'Subscription pause not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(subscriptionPausesTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete subscription pause', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to delete subscription pause', errorCodes.DATABASE_ERROR);
  }
}
