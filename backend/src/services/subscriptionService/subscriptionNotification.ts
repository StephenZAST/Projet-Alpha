import { createClient } from '@supabase/supabase-js';
import { SubscriptionNotification } from '../../models/subscription';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const subscriptionNotificationsTable = 'subscriptionNotifications';

export async function getSubscriptionNotification(id: string): Promise<SubscriptionNotification | null> {
  try {
    const { data, error } = await supabase.from(subscriptionNotificationsTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch subscription notification', errorCodes.DATABASE_ERROR);
    }

    return data as SubscriptionNotification;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch subscription notification', errorCodes.DATABASE_ERROR);
  }
}

export async function createSubscriptionNotification(notificationData: SubscriptionNotification): Promise<SubscriptionNotification> {
  try {
    const { data, error } = await supabase.from(subscriptionNotificationsTable).insert([notificationData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create subscription notification', errorCodes.DATABASE_ERROR);
    }

    return data as SubscriptionNotification;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to create subscription notification', errorCodes.DATABASE_ERROR);
  }
}

export async function updateSubscriptionNotification(id: string, notificationData: Partial<SubscriptionNotification>): Promise<SubscriptionNotification> {
  try {
    const currentNotification = await getSubscriptionNotification(id);

    if (!currentNotification) {
      throw new AppError(404, 'Subscription notification not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(subscriptionNotificationsTable).update(notificationData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update subscription notification', errorCodes.DATABASE_ERROR);
    }

    return data as SubscriptionNotification;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update subscription notification', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteSubscriptionNotification(id: string): Promise<void> {
  try {
    const notification = await getSubscriptionNotification(id);

    if (!notification) {
      throw new AppError(404, 'Subscription notification not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(subscriptionNotificationsTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete subscription notification', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to delete subscription notification', errorCodes.DATABASE_ERROR);
  }
}
