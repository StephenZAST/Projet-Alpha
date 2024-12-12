import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export interface Commission {
  id?: string;
  adminId: string;
  affiliateId: string;
  amount: number;
  status: 'pending' | 'paid' | 'failed';
  createdAt?: string;
  updatedAt?: string;
}

// Use Supabase to store commission data
const commissionsTable = 'commissions';

// Function to get commission data
export async function getCommission(id: string): Promise<Commission | null> {
  const { data, error } = await supabase.from(commissionsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch commission', 'INTERNAL_SERVER_ERROR');
  }

  return data as Commission;
}

// Function to create commission
export async function createCommission(commissionData: Commission): Promise<Commission> {
  const { data, error } = await supabase.from(commissionsTable).insert([commissionData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create commission', 'INTERNAL_SERVER_ERROR');
  }

  return data as Commission;
}

// Function to update commission
export async function updateCommission(id: string, commissionData: Partial<Commission>): Promise<Commission> {
  const currentCommission = await getCommission(id);

  if (!currentCommission) {
    throw new AppError(404, 'Commission not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(commissionsTable).update(commissionData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update commission', 'INTERNAL_SERVER_ERROR');
  }

  return data as Commission;
}

// Function to delete commission
export async function deleteCommission(id: string): Promise<void> {
  const commission = await getCommission(id);

  if (!commission) {
    throw new AppError(404, 'Commission not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(commissionsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete commission', 'INTERNAL_SERVER_ERROR');
  }
}
