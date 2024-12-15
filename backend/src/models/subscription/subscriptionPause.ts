import supabase from '../../config/supabase';
import { AppError, errorCodes } from '../../utils/errors';

export interface SubscriptionPause {
  startDate: string;
  endDate?: string;
  reason: string;
  requestedBy: string;
  status: 'active' | 'scheduled' | 'completed' | 'cancelled';
}

// Use Supabase to store subscription pause data
const subscriptionPausesTable = 'subscriptionPauses';

// Function to get subscription pause data
export async function getSubscriptionPause(id: string): Promise<SubscriptionPause | null> {
  const { data, error } = await supabase.from(subscriptionPausesTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch subscription pause', 'INTERNAL_SERVER_ERROR');
  }

  return data as SubscriptionPause;
}

// Function to create subscription pause
export async function createSubscriptionPause(pauseData: SubscriptionPause): Promise<SubscriptionPause> {
  const { data, error } = await supabase.from(subscriptionPausesTable).insert([pauseData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create subscription pause', 'INTERNAL_SERVER_ERROR');
  }

  return data as SubscriptionPause;
}

// Function to update subscription pause
export async function updateSubscriptionPause(id: string, pauseData: Partial<SubscriptionPause>): Promise<SubscriptionPause> {
  const currentPause = await getSubscriptionPause(id);

  if (!currentPause) {
    throw new AppError(404, 'Subscription pause not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(subscriptionPausesTable).update(pauseData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update subscription pause', 'INTERNAL_SERVER_ERROR');
  }

  return data as SubscriptionPause;
}

// Function to delete subscription pause
export async function deleteSubscriptionPause(id: string): Promise<void> {
  const pause = await getSubscriptionPause(id);

  if (!pause) {
    throw new AppError(404, 'Subscription pause not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(subscriptionPausesTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete subscription pause', 'INTERNAL_SERVER_ERROR');
  }
}
