import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export interface Referral {
  id: string;
  referrerId: string; // ID de l'utilisateur qui parraine
  referredId: string; // ID de l'utilisateur parrainé
  referralCode: string;
  status: 'PENDING' | 'ACTIVE' | 'EXPIRED';
  pointsEarned: number;
  ordersCount: number;
  firstOrderCompleted: boolean;
  createdAt: string;
  activatedAt?: string;
  expiresAt?: string;
}

export interface ReferralReward {
  id: string;
  referralId: string;
  referrerId: string;
  referredId: string;
  type: 'POINTS' | 'DISCOUNT' | 'CASH';
  value: number;
  status: 'PENDING' | 'CREDITED' | 'EXPIRED';
  orderId?: string;
  createdAt: string;
  creditedAt?: string;
}

export interface ReferralProgram {
  id: string;
  name: string;
  description: string;
  referrerReward: {
    type: 'POINTS' | 'DISCOUNT' | 'CASH';
    value: number;
  };
  referredReward: {
    type: 'POINTS' | 'DISCOUNT' | 'CASH';
    value: number;
  };
  minimumOrderValue: number;
  validityPeriod: number; // en jours
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

// Use Supabase to store referral data
const referralsTable = 'referrals';
const referralRewardsTable = 'referralRewards';
const referralProgramsTable = 'referralPrograms';

// Function to get referral data
export async function getReferral(id: string): Promise<Referral | null> {
  const { data, error } = await supabase.from(referralsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch referral', 'INTERNAL_SERVER_ERROR');
  }

  return data as Referral;
}

// Function to create referral
export async function createReferral(referralData: Referral): Promise<Referral> {
  const { data, error } = await supabase.from(referralsTable).insert([referralData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create referral', 'INTERNAL_SERVER_ERROR');
  }

  return data as Referral;
}

// Function to update referral
export async function updateReferral(id: string, referralData: Partial<Referral>): Promise<Referral> {
  const currentReferral = await getReferral(id);

  if (!currentReferral) {
    throw new AppError(404, 'Referral not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(referralsTable).update(referralData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update referral', 'INTERNAL_SERVER_ERROR');
  }

  return data as Referral;
}

// Function to delete referral
export async function deleteReferral(id: string): Promise<void> {
  const referral = await getReferral(id);

  if (!referral) {
    throw new AppError(404, 'Referral not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(referralsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete referral', 'INTERNAL_SERVER_ERROR');
  }
}

// Function to get referral reward data
export async function getReferralReward(id: string): Promise<ReferralReward | null> {
  const { data, error } = await supabase.from(referralRewardsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch referral reward', 'INTERNAL_SERVER_ERROR');
  }

  return data as ReferralReward;
}

// Function to create referral reward
export async function createReferralReward(rewardData: ReferralReward): Promise<ReferralReward> {
  const { data, error } = await supabase.from(referralRewardsTable).insert([rewardData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create referral reward', 'INTERNAL_SERVER_ERROR');
  }

  return data as ReferralReward;
}

// Function to update referral reward
export async function updateReferralReward(id: string, rewardData: Partial<ReferralReward>): Promise<ReferralReward> {
  const currentReward = await getReferralReward(id);

  if (!currentReward) {
    throw new AppError(404, 'Referral reward not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(referralRewardsTable).update(rewardData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update referral reward', 'INTERNAL_SERVER_ERROR');
  }

  return data as ReferralReward;
}

// Function to delete referral reward
export async function deleteReferralReward(id: string): Promise<void> {
  const reward = await getReferralReward(id);

  if (!reward) {
    throw new AppError(404, 'Referral reward not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(referralRewardsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete referral reward', 'INTERNAL_SERVER_ERROR');
  }
}

// Function to get referral program data
export async function getReferralProgram(id: string): Promise<ReferralProgram | null> {
  const { data, error } = await supabase.from(referralProgramsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch referral program', 'INTERNAL_SERVER_ERROR');
  }

  return data as ReferralProgram;
}

// Function to create referral program
export async function createReferralProgram(programData: ReferralProgram): Promise<ReferralProgram> {
  const { data, error } = await supabase.from(referralProgramsTable).insert([programData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create referral program', 'INTERNAL_SERVER_ERROR');
  }

  return data as ReferralProgram;
}

// Function to update referral program
export async function updateReferralProgram(id: string, programData: Partial<ReferralProgram>): Promise<ReferralProgram> {
  const currentProgram = await getReferralProgram(id);

  if (!currentProgram) {
    throw new AppError(404, 'Referral program not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(referralProgramsTable).update(programData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update referral program', 'INTERNAL_SERVER_ERROR');
  }

  return data as ReferralProgram;
}

// Function to delete referral program
export async function deleteReferralProgram(id: string): Promise<void> {
  const program = await getReferralProgram(id);

  if (!program) {
    throw new AppError(404, 'Referral program not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(referralProgramsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete referral program', 'INTERNAL_SERVER_ERROR');
  }
}
