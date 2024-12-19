import { supabase } from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';
import { LoyaltyTier } from './loyalty/loyaltyAccount';

export enum RewardType {
  POINTS = 'POINTS',
  DISCOUNT = 'DISCOUNT',
  GIFT = 'GIFT'
}

export enum RewardStatus {
  AVAILABLE = 'available',
  REDEEMED = 'redeemed',
  CLAIMED = 'claimed',
  EXPIRED = 'expired'
}

export interface Reward {
  id: string;
  name: string;
  description: string;
  type: RewardType;
  category: string;
  pointsCost: number;
  quantity: number;
  startDate: string;
  endDate?: string;
  tier?: LoyaltyTier;
  metadata: {
    discountPercentage?: number;
    digitalCode?: string;
    shippingWeight?: number;
  };
  discountAmount?: number; // Added discountAmount property
  pointsRequired?: number; // Added pointsRequired property
  isActive: boolean;
  redemptionCount: number;
  createdAt: string;
  updatedAt?: string;
}

// Use Supabase to store reward data
const rewardsTable = 'rewards';

// Function to get reward data
export async function getReward(id: string): Promise<Reward | null> {
  const { data, error } = await supabase.from(rewardsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch reward', 'INTERNAL_SERVER_ERROR');
  }

  return data as Reward;
}

// Function to create reward
export async function createReward(rewardData: Reward): Promise<Reward> {
  const { data, error } = await supabase.from(rewardsTable).insert([rewardData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create reward', 'INTERNAL_SERVER_ERROR');
  }

  return data as Reward;
}

// Function to update reward
export async function updateReward(id: string, rewardData: Partial<Reward>): Promise<Reward> {
  const currentReward = await getReward(id);

  if (!currentReward) {
    throw new AppError(404, 'Reward not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(rewardsTable).update(rewardData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update reward', 'INTERNAL_SERVER_ERROR');
  }

  return data as Reward;
}

// Function to delete reward
export async function deleteReward(id: string): Promise<void> {
  const reward = await getReward(id);

  if (!reward) {
    throw new AppError(404, 'Reward not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(rewardsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete reward', 'INTERNAL_SERVER_ERROR');
  }
}
