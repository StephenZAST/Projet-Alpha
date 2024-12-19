import { createClient } from '@supabase/supabase-js';
import { ReferralReward } from '../../models/referral';
import { AppError, errorCodes } from '../../utils/errors';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL or SUPABASE_SERVICE_KEY environment variables not set.');
}

const supabase = createClient(supabaseUrl as string, supabaseKey as string);

const rewardsTable = 'referral-rewards';

/**
 * Get referral reward by id
 */
export async function getReferralReward(id: string): Promise<ReferralReward | null> {
  try {
    const { data, error } = await supabase.from(rewardsTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch referral reward', errorCodes.DATABASE_ERROR);
    }

    return data as ReferralReward;
  } catch (error) {
    console.error('Error getting referral reward:', error);
    throw error;
  }
}

/**
 * Create a new referral reward
 */
export async function createReferralReward(rewardData: Omit<ReferralReward, 'id'>): Promise<ReferralReward> {
  try {
    const { data, error } = await supabase.from(rewardsTable).insert([rewardData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create referral reward', errorCodes.DATABASE_ERROR);
    }

    return { ...rewardData, id: data.id } as ReferralReward;
  } catch (error) {
    console.error('Error creating referral reward:', error);
    throw error;
  }
}

/**
 * Update a referral reward
 */
export async function updateReferralReward(id: string, rewardData: Partial<ReferralReward>): Promise<ReferralReward> {
  try {
    const currentReward = await getReferralReward(id);

    if (!currentReward) {
      throw new AppError(404, 'Referral reward not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(rewardsTable).update(rewardData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update referral reward', errorCodes.DATABASE_ERROR);
    }

    return { ...currentReward, ...rewardData } as ReferralReward;
  } catch (error) {
    console.error('Error updating referral reward:', error);
    throw error;
  }
}

/**
 * Delete a referral reward
 */
export async function deleteReferralReward(id: string): Promise<void> {
  try {
    const reward = await getReferralReward(id);

    if (!reward) {
      throw new AppError(404, 'Referral reward not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(rewardsTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete referral reward', errorCodes.DATABASE_ERROR);
    }
  } catch (error) {
    console.error('Error deleting referral reward:', error);
    throw error;
  }
}
