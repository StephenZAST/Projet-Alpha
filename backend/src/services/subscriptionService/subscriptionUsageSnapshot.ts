import { createClient } from '@supabase/supabase-js';
import { SubscriptionUsageSnapshot } from '../../models/subscription';
import { AppError, errorCodes } from '../../utils/errors';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL or SUPABASE_SERVICE_KEY environment variables not set.');
}

const supabase = createClient(supabaseUrl as string, supabaseKey as string);

const subscriptionUsageSnapshotsTable = 'subscriptionUsageSnapshots';

export async function getSubscriptionUsageSnapshot(id: string): Promise<SubscriptionUsageSnapshot | null> {
  try {
    const { data, error } = await supabase.from(subscriptionUsageSnapshotsTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch subscription usage snapshot', errorCodes.DATABASE_ERROR);
    }

    return data as SubscriptionUsageSnapshot;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch subscription usage snapshot', errorCodes.DATABASE_ERROR);
  }
}

export async function createSubscriptionUsageSnapshot(snapshotData: SubscriptionUsageSnapshot): Promise<SubscriptionUsageSnapshot> {
  try {
    const { data, error } = await supabase.from(subscriptionUsageSnapshotsTable).insert([snapshotData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create subscription usage snapshot', errorCodes.DATABASE_ERROR);
    }

    return data as SubscriptionUsageSnapshot;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to create subscription usage snapshot', errorCodes.DATABASE_ERROR);
  }
}

export async function updateSubscriptionUsageSnapshot(id: string, snapshotData: Partial<SubscriptionUsageSnapshot>): Promise<SubscriptionUsageSnapshot> {
  try {
    const currentSnapshot = await getSubscriptionUsageSnapshot(id);

    if (!currentSnapshot) {
      throw new AppError(404, 'Subscription usage snapshot not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(subscriptionUsageSnapshotsTable).update(snapshotData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update subscription usage snapshot', errorCodes.DATABASE_ERROR);
    }

    return data as SubscriptionUsageSnapshot;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update subscription usage snapshot', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteSubscriptionUsageSnapshot(id: string): Promise<void> {
  try {
    const snapshot = await getSubscriptionUsageSnapshot(id);

    if (!snapshot) {
      throw new AppError(404, 'Subscription usage snapshot not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(subscriptionUsageSnapshotsTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete subscription usage snapshot', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to delete subscription usage snapshot', errorCodes.DATABASE_ERROR);
  }
}
