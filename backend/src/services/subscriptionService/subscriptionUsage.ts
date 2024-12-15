import { createClient } from '@supabase/supabase-js';
import { SubscriptionUsage } from '../../models/subscription';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const subscriptionUsagesTable = 'subscriptionUsages';

export async function getSubscriptionUsage(id: string): Promise<SubscriptionUsage | null> {
  try {
    const { data, error } = await supabase.from(subscriptionUsagesTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch subscription usage', errorCodes.DATABASE_ERROR);
    }

    return data as SubscriptionUsage;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch subscription usage', errorCodes.DATABASE_ERROR);
  }
}

export async function createSubscriptionUsage(usageData: SubscriptionUsage): Promise<SubscriptionUsage> {
  try {
    const { data, error } = await supabase.from(subscriptionUsagesTable).insert([usageData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create subscription usage', errorCodes.DATABASE_ERROR);
    }

    return data as SubscriptionUsage;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to create subscription usage', errorCodes.DATABASE_ERROR);
  }
}

export async function updateSubscriptionUsage(id: string, usageData: Partial<SubscriptionUsage>): Promise<SubscriptionUsage> {
  try {
    const currentUsage = await getSubscriptionUsage(id);

    if (!currentUsage) {
      throw new AppError(404, 'Subscription usage not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(subscriptionUsagesTable).update(usageData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update subscription usage', errorCodes.DATABASE_ERROR);
    }

    return data as SubscriptionUsage;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update subscription usage', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteSubscriptionUsage(id: string): Promise<void> {
  try {
    const usage = await getSubscriptionUsage(id);

    if (!usage) {
      throw new AppError(404, 'Subscription usage not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(subscriptionUsagesTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete subscription usage', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to delete subscription usage', errorCodes.DATABASE_ERROR);
  }
}
