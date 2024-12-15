import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';
import { SubscriptionType } from './subscription/subscriptionPlan';
import { SubscriptionPause } from './subscription/subscriptionPause';
import { SubscriptionBilling } from './subscription/subscriptionBilling';
import { SubscriptionUsageSnapshot } from './subscription/subscriptionUsage';

export enum SubscriptionStatus {
  ACTIVE = 'active',
  CANCELLED = 'cancelled',
  EXPIRED = 'expired',
  SUSPENDED = 'suspended',
  PENDING = 'pending',
  PAUSED = 'paused',
  TRIAL = 'trial'
}

export interface Subscription {
  id?: string;
  userId: string;
  planId: string;
  type: SubscriptionType;
  startDate: string;
  endDate?: string;
  status: SubscriptionStatus;
  pricePerMonth: number;
  weightLimitPerWeek: number;
  description: string;
  createdAt: string;
  updatedAt: string;
  cancellationDate?: string;
  cancellationReason?: string;
  autoRenew: boolean;
  paymentMethod?: string;
  lastBillingDate?: string;
  nextBillingDate?: string;
  pauseHistory?: SubscriptionPause[];
  billingHistory?: SubscriptionBilling[];
  usageHistory?: SubscriptionUsageSnapshot[];
  currentPeriodStart?: string;
  currentPeriodEnd?: string;
  trialEnd?: string;
  discount?: {
    percentage: number;
    endDate: string;
    reason: string;
  };
}

// Use Supabase to store subscription data
const subscriptionsTable = 'subscriptions';

// Function to get subscription data
export async function getSubscription(id: string): Promise<Subscription | null> {
  const { data, error } = await supabase.from(subscriptionsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch subscription', 'INTERNAL_SERVER_ERROR');
  }

  return data as Subscription;
}

// Function to create subscription
export async function createSubscription(subscriptionData: Subscription): Promise<Subscription> {
  const { data, error } = await supabase.from(subscriptionsTable).insert([subscriptionData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create subscription', 'INTERNAL_SERVER_ERROR');
  }

  return data as Subscription;
}

// Function to update subscription
export async function updateSubscription(id: string, subscriptionData: Partial<Subscription>): Promise<Subscription> {
  const currentSubscription = await getSubscription(id);

  if (!currentSubscription) {
    throw new AppError(404, 'Subscription not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(subscriptionsTable).update(subscriptionData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update subscription', 'INTERNAL_SERVER_ERROR');
  }

  return data as Subscription;
}

// Function to delete subscription
export async function deleteSubscription(id: string): Promise<void> {
  const subscription = await getSubscription(id);

  if (!subscription) {
    throw new AppError(404, 'Subscription not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(subscriptionsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete subscription', 'INTERNAL_SERVER_ERROR');
  }
}
