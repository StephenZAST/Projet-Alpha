import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export interface SubscriptionUsage {
  id?: string;
  subscriptionId: string;
  userId: string;
  periodStart: string;
  periodEnd: string;
  itemsUsed: number;
  weightUsed: number;
  remainingItems: number;
  remainingWeight: number;
  lastUpdated: string;
  servicesUsed: {
    mainServices: { [key: string]: number };
    additionalServices: { [key: string]: number };
  };
  overageCharges?: number;
  notifications?: SubscriptionNotification[];
}

export interface SubscriptionNotification {
  type: 'usage_warning' | 'payment_due' | 'renewal_reminder' | 'expiration_warning';
  message: string;
  date: string;
  isRead: boolean;
  actionRequired: boolean;
}

export interface SubscriptionUsageSnapshot {
  date: string;
  itemsUsed: number;
  weightUsed: number;
  overageCharges: number;
}

// Use Supabase to store subscription usage data
const subscriptionUsagesTable = 'subscriptionUsages';
const subscriptionNotificationsTable = 'subscriptionNotifications';
const subscriptionUsageSnapshotsTable = 'subscriptionUsageSnapshots';

// Function to get subscription usage data
export async function getSubscriptionUsage(id: string): Promise<SubscriptionUsage | null> {
  const { data, error } = await supabase.from(subscriptionUsagesTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch subscription usage', 'INTERNAL_SERVER_ERROR');
  }

  return data as SubscriptionUsage;
}

// Function to create subscription usage
export async function createSubscriptionUsage(usageData: SubscriptionUsage): Promise<SubscriptionUsage> {
  const { data, error } = await supabase.from(subscriptionUsagesTable).insert([usageData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create subscription usage', 'INTERNAL_SERVER_ERROR');
  }

  return data as SubscriptionUsage;
}

// Function to update subscription usage
export async function updateSubscriptionUsage(id: string, usageData: Partial<SubscriptionUsage>): Promise<SubscriptionUsage> {
  const currentUsage = await getSubscriptionUsage(id);

  if (!currentUsage) {
    throw new AppError(404, 'Subscription usage not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(subscriptionUsagesTable).update(usageData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update subscription usage', 'INTERNAL_SERVER_ERROR');
  }

  return data as SubscriptionUsage;
}

// Function to delete subscription usage
export async function deleteSubscriptionUsage(id: string): Promise<void> {
  const usage = await getSubscriptionUsage(id);

  if (!usage) {
    throw new AppError(404, 'Subscription usage not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(subscriptionUsagesTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete subscription usage', 'INTERNAL_SERVER_ERROR');
  }
}

// Function to get subscription notification data
export async function getSubscriptionNotification(id: string): Promise<SubscriptionNotification | null> {
  const { data, error } = await supabase.from(subscriptionNotificationsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch subscription notification', 'INTERNAL_SERVER_ERROR');
  }

  return data as SubscriptionNotification;
}

// Function to create subscription notification
export async function createSubscriptionNotification(notificationData: SubscriptionNotification): Promise<SubscriptionNotification> {
  const { data, error } = await supabase.from(subscriptionNotificationsTable).insert([notificationData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create subscription notification', 'INTERNAL_SERVER_ERROR');
  }

  return data as SubscriptionNotification;
}

// Function to update subscription notification
export async function updateSubscriptionNotification(id: string, notificationData: Partial<SubscriptionNotification>): Promise<SubscriptionNotification> {
  const currentNotification = await getSubscriptionNotification(id);

  if (!currentNotification) {
    throw new AppError(404, 'Subscription notification not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(subscriptionNotificationsTable).update(notificationData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update subscription notification', 'INTERNAL_SERVER_ERROR');
  }

  return data as SubscriptionNotification;
}

// Function to delete subscription notification
export async function deleteSubscriptionNotification(id: string): Promise<void> {
  const notification = await getSubscriptionNotification(id);

  if (!notification) {
    throw new AppError(404, 'Subscription notification not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(subscriptionNotificationsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete subscription notification', 'INTERNAL_SERVER_ERROR');
  }
}

// Function to get subscription usage snapshot data
export async function getSubscriptionUsageSnapshot(id: string): Promise<SubscriptionUsageSnapshot | null> {
  const { data, error } = await supabase.from(subscriptionUsageSnapshotsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch subscription usage snapshot', 'INTERNAL_SERVER_ERROR');
  }

  return data as SubscriptionUsageSnapshot;
}

// Function to create subscription usage snapshot
export async function createSubscriptionUsageSnapshot(snapshotData: SubscriptionUsageSnapshot): Promise<SubscriptionUsageSnapshot> {
  const { data, error } = await supabase.from(subscriptionUsageSnapshotsTable).insert([snapshotData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create subscription usage snapshot', 'INTERNAL_SERVER_ERROR');
  }

  return data as SubscriptionUsageSnapshot;
}

// Function to update subscription usage snapshot
export async function updateSubscriptionUsageSnapshot(id: string, snapshotData: Partial<SubscriptionUsageSnapshot>): Promise<SubscriptionUsageSnapshot> {
  const currentSnapshot = await getSubscriptionUsageSnapshot(id);

  if (!currentSnapshot) {
    throw new AppError(404, 'Subscription usage snapshot not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(subscriptionUsageSnapshotsTable).update(snapshotData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update subscription usage snapshot', 'INTERNAL_SERVER_ERROR');
  }

  return data as SubscriptionUsageSnapshot;
}

// Function to delete subscription usage snapshot
export async function deleteSubscriptionUsageSnapshot(id: string): Promise<void> {
  const snapshot = await getSubscriptionUsageSnapshot(id);

  if (!snapshot) {
    throw new AppError(404, 'Subscription usage snapshot not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(subscriptionUsageSnapshotsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete subscription usage snapshot', 'INTERNAL_SERVER_ERROR');
  }
}
