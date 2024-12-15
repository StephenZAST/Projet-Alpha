import { createClient } from '@supabase/supabase-js';
import { Subscription, SubscriptionStatus, SubscriptionType } from '../../models/subscription';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const subscriptionsTable = 'subscriptions';

export async function getSubscription(id: string): Promise<Subscription | null> {
  try {
    const { data, error } = await supabase.from(subscriptionsTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch subscription', errorCodes.DATABASE_ERROR);
    }

    return data as Subscription;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch subscription', errorCodes.DATABASE_ERROR);
  }
}

export async function createSubscription(subscriptionData: Subscription): Promise<Subscription> {
  try {
    const { data, error } = await supabase.from(subscriptionsTable).insert([subscriptionData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create subscription', errorCodes.DATABASE_ERROR);
    }

    return data as Subscription;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to create subscription', errorCodes.DATABASE_ERROR);
  }
}

export async function updateSubscription(id: string, subscriptionData: Partial<Subscription>): Promise<Subscription> {
  try {
    const currentSubscription = await getSubscription(id);

    if (!currentSubscription) {
      throw new AppError(404, 'Subscription not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(subscriptionsTable).update(subscriptionData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update subscription', errorCodes.DATABASE_ERROR);
    }

    return data as Subscription;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update subscription', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteSubscription(id: string): Promise<void> {
  try {
    const subscription = await getSubscription(id);

    if (!subscription) {
      throw new AppError(404, 'Subscription not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(subscriptionsTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete subscription', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to delete subscription', errorCodes.DATABASE_ERROR);
  }
}
