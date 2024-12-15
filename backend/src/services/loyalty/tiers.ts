import { createClient } from '@supabase/supabase-js';
import { LoyaltyTierConfig } from '../../models/loyalty';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const loyaltyTiersTable = 'loyaltyTiers';

export async function updateLoyaltyTier(
  tierId: string,
  tierData: Partial<LoyaltyTierConfig>
): Promise<LoyaltyTierConfig> {
  try {
    const { data, error } = await supabase.from(loyaltyTiersTable).update(tierData).eq('id', tierId).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update loyalty tier', errorCodes.DATABASE_ERROR);
    }

    if (!data) {
      throw new AppError(404, 'Loyalty tier not found', errorCodes.NOT_FOUND);
    }

    return data as LoyaltyTierConfig;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update loyalty tier', errorCodes.DATABASE_ERROR);
  }
}

export async function getLoyaltyTiers(): Promise<LoyaltyTierConfig[]> {
  try {
    const { data, error } = await supabase.from(loyaltyTiersTable).select('*').order('pointsThreshold', { ascending: true });

    if (error) {
      throw new AppError(500, 'Failed to fetch loyalty tiers', errorCodes.DATABASE_ERROR);
    }

    return data as LoyaltyTierConfig[];
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch loyalty tiers', errorCodes.DATABASE_ERROR);
  }
}
