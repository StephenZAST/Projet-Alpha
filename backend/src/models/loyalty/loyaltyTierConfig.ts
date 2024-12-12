import supabase from '../../config/supabase';
import { AppError, errorCodes } from '../../utils/errors';

export interface TierBenefit {
  type: 'discount' | 'freeShipping' | 'pointsMultiplier' | 'exclusiveAccess';
  value: number | boolean;
  description: string;
}

export interface LoyaltyTierConfig {
  id: string;
  name: string;
  description: string;
  pointsThreshold: number;
  benefits: TierBenefit[];
  icon?: string;
  color?: string;
  status: 'active' | 'inactive';
  createdAt: string;
  updatedAt: string;
}

// Use Supabase to store loyalty tier config data
const loyaltyTierConfigsTable = 'loyaltyTierConfigs';

// Function to get loyalty tier config data
export async function getLoyaltyTierConfig(id: string): Promise<LoyaltyTierConfig | null> {
  const { data, error } = await supabase.from(loyaltyTierConfigsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch loyalty tier config', 'INTERNAL_SERVER_ERROR');
  }

  return data as LoyaltyTierConfig;
}

// Function to create loyalty tier config
export async function createLoyaltyTierConfig(configData: LoyaltyTierConfig): Promise<LoyaltyTierConfig> {
  const { data, error } = await supabase.from(loyaltyTierConfigsTable).insert([configData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create loyalty tier config', 'INTERNAL_SERVER_ERROR');
  }

  return data as LoyaltyTierConfig;
}

// Function to update loyalty tier config
export async function updateLoyaltyTierConfig(id: string, configData: Partial<LoyaltyTierConfig>): Promise<LoyaltyTierConfig> {
  const currentConfig = await getLoyaltyTierConfig(id);

  if (!currentConfig) {
    throw new AppError(404, 'Loyalty tier config not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(loyaltyTierConfigsTable).update(configData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update loyalty tier config', 'INTERNAL_SERVER_ERROR');
  }

  return data as LoyaltyTierConfig;
}

// Function to delete loyalty tier config
export async function deleteLoyaltyTierConfig(id: string): Promise<void> {
  const config = await getLoyaltyTierConfig(id);

  if (!config) {
    throw new AppError(404, 'Loyalty tier config not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(loyaltyTierConfigsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete loyalty tier config', 'INTERNAL_SERVER_ERROR');
  }
}
