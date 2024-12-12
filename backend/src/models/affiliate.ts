import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export interface Affiliate {
  id?: string;
  name: string;
  email: string;
  phoneNumber: string;
  address: string;
  status: 'active' | 'inactive';
  createdAt?: string;
  updatedAt?: string;
}

// Use Supabase to store affiliate data
const affiliatesTable = 'affiliates';

// Function to get affiliate data
export async function getAffiliate(id: string): Promise<Affiliate | null> {
  const { data, error } = await supabase.from(affiliatesTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch affiliate', 'INTERNAL_SERVER_ERROR');
  }

  return data as Affiliate;
}

// Function to create affiliate
export async function createAffiliate(affiliateData: Affiliate): Promise<Affiliate> {
  const { data, error } = await supabase.from(affiliatesTable).insert([affiliateData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create affiliate', 'INTERNAL_SERVER_ERROR');
  }

  return data as Affiliate;
}

// Function to update affiliate
export async function updateAffiliate(id: string, affiliateData: Partial<Affiliate>): Promise<Affiliate> {
  const currentAffiliate = await getAffiliate(id);

  if (!currentAffiliate) {
    throw new AppError(404, 'Affiliate not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(affiliatesTable).update(affiliateData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update affiliate', 'INTERNAL_SERVER_ERROR');
  }

  return data as Affiliate;
}

// Function to delete affiliate
export async function deleteAffiliate(id: string): Promise<void> {
  const affiliate = await getAffiliate(id);

  if (!affiliate) {
    throw new AppError(404, 'Affiliate not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(affiliatesTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete affiliate', 'INTERNAL_SERVER_ERROR');
  }
}
