import { createClient } from '@supabase/supabase-js';
import { AppError, errorCodes } from '../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const subscriptionsTable = 'subscriptions';
const userSubscriptionsTable = 'userSubscriptions';

export interface Subscription {
  id: string;
  name: string;
  price: number;
  weightLimitPerWeek: number;
  description: string;
  features: string[];
  isActive: boolean;
}

export interface UserSubscription {
  id: string;
  userId: string;
  subscriptionId: string;
  startDate: string;
  endDate: string;
  status: 'active' | 'cancelled' | 'expired';
}

/**
 * Get all subscriptions
 */
export async function getSubscriptions(): Promise<Subscription[]> {
  try {
    const { data, error } = await supabase.from(subscriptionsTable).select('*');

    if (error) {
      throw new AppError(500, 'Failed to fetch subscriptions', errorCodes.DATABASE_ERROR);
    }

    return data as Subscription[];
  } catch (error) {
    console.error('Error fetching subscriptions:', error);
    throw error;
  }
}

/**
 * Create a new subscription
 */
export async function createSubscription(subscriptionData: Omit<Subscription, 'id'>): Promise<Subscription> {
  try {
    const { data, error } = await supabase.from(subscriptionsTable).insert([subscriptionData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create subscription', errorCodes.DATABASE_ERROR);
    }

    return { ...subscriptionData, id: data.id } as Subscription;
  } catch (error) {
    console.error('Error creating subscription:', error);
    throw error;
  }
}

/**
 * Update a subscription
 */
export async function updateSubscription(subscriptionId: string, subscriptionData: Partial<Subscription>): Promise<Subscription> {
  try {
    const { data, error } = await supabase.from(subscriptionsTable).update(subscriptionData).eq('id', subscriptionId).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update subscription', errorCodes.DATABASE_ERROR);
    }

    return { ...subscriptionData, id: subscriptionId } as Subscription;
  } catch (error) {
    console.error('Error updating subscription:', error);
    throw error;
  }
}

/**
 * Delete a subscription
 */
export async function deleteSubscription(subscriptionId: string): Promise<void> {
  try {
    const { error } = await supabase.from(subscriptionsTable).delete().eq('id', subscriptionId);

    if (error) {
      throw new AppError(500, 'Failed to delete subscription', errorCodes.DATABASE_ERROR);
    }
  } catch (error) {
    console.error('Error deleting subscription:', error);
    throw error;
  }
}

/**
 * Get user subscription
 */
export async function getUserSubscription(userId: string): Promise<UserSubscription | null> {
  try {
    const { data, error } = await supabase.from(userSubscriptionsTable)
      .select('*')
      .eq('userId', userId)
      .eq('status', 'active')
      .single();

    if (error) {
      if (error.status === 404) {
        return null;
      }
      throw new AppError(500, 'Failed to fetch user subscription', errorCodes.DATABASE_ERROR);
    }

    return data as UserSubscription;
  } catch (error) {
    console.error('Error fetching user subscription:', error);
    throw error;
  }
}
