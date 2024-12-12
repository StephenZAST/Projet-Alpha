import supabase from '../../config/supabase';
import { AppError, errorCodes } from '../../utils/errors';

export interface LoyaltyReward {
  id?: string;
  name: string;
  description: string;
  pointsCost: number;
  type: 'discount' | 'freeService' | 'gift';
  value: number; // Pourcentage de réduction ou valeur monétaire
  minOrderAmount?: number;
  maxDiscount?: number;
  validFrom: string;
  validUntil: string;
  isActive: boolean;
  termsAndConditions?: string;
  limitPerUser?: number;
  totalLimit?: number;
  redemptionCount: number;
}

// Use Supabase to store loyalty reward data
const loyaltyRewardsTable = 'loyaltyRewards';

// Function to get loyalty reward data
export async function getLoyaltyReward(id: string): Promise<LoyaltyReward | null> {
  const { data, error } = await supabase.from(loyaltyRewardsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch loyalty reward', 'INTERNAL_SERVER_ERROR');
  }

  return data as LoyaltyReward;
}

// Function to create loyalty reward
export async function createLoyaltyReward(rewardData: LoyaltyReward): Promise<LoyaltyReward> {
  const { data, error } = await supabase.from(loyaltyRewardsTable).insert([rewardData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create loyalty reward', 'INTERNAL_SERVER_ERROR');
  }

  return data as LoyaltyReward;
}

// Function to update loyalty reward
export async function updateLoyaltyReward(id: string, rewardData: Partial<LoyaltyReward>): Promise<LoyaltyReward> {
  const currentReward = await getLoyaltyReward(id);

  if (!currentReward) {
    throw new AppError(404, 'Loyalty reward not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(loyaltyRewardsTable).update(rewardData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update loyalty reward', 'INTERNAL_SERVER_ERROR');
  }

  return data as LoyaltyReward;
}

// Function to delete loyalty reward
export async function deleteLoyaltyReward(id: string): Promise<void> {
  const reward = await getLoyaltyReward(id);

  if (!reward) {
    throw new AppError(404, 'Loyalty reward not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(loyaltyRewardsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete loyalty reward', 'INTERNAL_SERVER_ERROR');
  }
}
