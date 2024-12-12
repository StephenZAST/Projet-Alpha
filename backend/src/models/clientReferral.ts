import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export interface ClientReferral {
  id: string;
  referrerId: string;           // Client qui parraine
  referredId: string;           // Nouveau client parrainé
  referralCode: string;
  status: 'PENDING' | 'COMPLETED';
  createdAt: string;
  completedAt?: string;
}

// Use Supabase to store client referral data
const clientReferralsTable = 'clientReferrals';

// Function to get client referral data
export async function getClientReferral(id: string): Promise<ClientReferral | null> {
  const { data, error } = await supabase.from(clientReferralsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch client referral', 'INTERNAL_SERVER_ERROR');
  }

  return data as ClientReferral;
}

// Function to create client referral
export async function createClientReferral(referralData: ClientReferral): Promise<ClientReferral> {
  const { data, error } = await supabase.from(clientReferralsTable).insert([referralData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create client referral', 'INTERNAL_SERVER_ERROR');
  }

  return data as ClientReferral;
}

// Function to update client referral
export async function updateClientReferral(id: string, referralData: Partial<ClientReferral>): Promise<ClientReferral> {
  const currentReferral = await getClientReferral(id);

  if (!currentReferral) {
    throw new AppError(404, 'Client referral not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(clientReferralsTable).update(referralData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update client referral', 'INTERNAL_SERVER_ERROR');
  }

  return data as ClientReferral;
}

// Function to delete client referral
export async function deleteClientReferral(id: string): Promise<void> {
  const referral = await getClientReferral(id);

  if (!referral) {
    throw new AppError(404, 'Client referral not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(clientReferralsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete client referral', 'INTERNAL_SERVER_ERROR');
  }
}
