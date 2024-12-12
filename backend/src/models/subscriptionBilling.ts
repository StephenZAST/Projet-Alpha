import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export interface SubscriptionBilling {
  date: string;
  amount: number;
  status: 'pending' | 'successful' | 'failed';
  paymentMethod: string;
  invoiceUrl?: string;
  failureReason?: string;
}

// Use Supabase to store subscription billing data
const subscriptionBillingsTable = 'subscriptionBillings';

// Function to get subscription billing data
export async function getSubscriptionBilling(id: string): Promise<SubscriptionBilling | null> {
  const { data, error } = await supabase.from(subscriptionBillingsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch subscription billing', 'INTERNAL_SERVER_ERROR');
  }

  return data as SubscriptionBilling;
}

// Function to create subscription billing
export async function createSubscriptionBilling(billingData: SubscriptionBilling): Promise<SubscriptionBilling> {
  const { data, error } = await supabase.from(subscriptionBillingsTable).insert([billingData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create subscription billing', 'INTERNAL_SERVER_ERROR');
  }

  return data as SubscriptionBilling;
}

// Function to update subscription billing
export async function updateSubscriptionBilling(id: string, billingData: Partial<SubscriptionBilling>): Promise<SubscriptionBilling> {
  const currentBilling = await getSubscriptionBilling(id);

  if (!currentBilling) {
    throw new AppError(404, 'Subscription billing not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(subscriptionBillingsTable).update(billingData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update subscription billing', 'INTERNAL_SERVER_ERROR');
  }

  return data as SubscriptionBilling;
}

// Function to delete subscription billing
export async function deleteSubscriptionBilling(id: string): Promise<void> {
  const billing = await getSubscriptionBilling(id);

  if (!billing) {
    throw new AppError(404, 'Subscription billing not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(subscriptionBillingsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete subscription billing', 'INTERNAL_SERVER_ERROR');
  }
}
