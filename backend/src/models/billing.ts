import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export interface Billing {
  id?: string;
  userId: string;
  amount: number;
  status: 'pending' | 'paid' | 'failed' | 'refunded';
  paymentMethod: string;
  createdAt?: string;
  updatedAt?: string;
}

// Use Supabase to store billing data
const billingTable = 'billing';

// Function to get billing data
export async function getBilling(id: string): Promise<Billing | null> {
  const { data, error } = await supabase.from(billingTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch billing', 'INTERNAL_SERVER_ERROR');
  }

  return data as Billing;
}

// Function to create billing
export async function createBilling(billingData: Billing): Promise<Billing> {
  const { data, error } = await supabase.from(billingTable).insert([billingData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create billing', 'INTERNAL_SERVER_ERROR');
  }

  return data as Billing;
}

// Function to update billing
export async function updateBilling(id: string, billingData: Partial<Billing>): Promise<Billing> {
  const currentBilling = await getBilling(id);

  if (!currentBilling) {
    throw new AppError(404, 'Billing not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(billingTable).update(billingData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update billing', 'INTERNAL_SERVER_ERROR');
  }

  return data as Billing;
}

// Function to delete billing
export async function deleteBilling(id: string): Promise<void> {
  const billing = await getBilling(id);

  if (!billing) {
    throw new AppError(404, 'Billing not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(billingTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete billing', 'INTERNAL_SERVER_ERROR');
  }
}
