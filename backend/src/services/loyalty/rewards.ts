import { createClient } from '@supabase/supabase-js';
import { LoyaltyReward, LoyaltyTransaction, LoyaltyTransactionType } from '../../models/loyalty';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const loyaltyRewardsTable = 'loyaltyRewards';
const loyaltyTransactionsTable = 'loyaltyTransactions';

export async function getLoyaltyReward(id: string): Promise<LoyaltyReward | null> {
  try {
    const { data, error } = await supabase.from(loyaltyRewardsTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch loyalty reward', errorCodes.DATABASE_ERROR);
    }

    return data as LoyaltyReward;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch loyalty reward', errorCodes.DATABASE_ERROR);
  }
}

export async function createLoyaltyReward(rewardData: LoyaltyReward): Promise<LoyaltyReward> {
  try {
    const { data, error } = await supabase.from(loyaltyRewardsTable).insert([rewardData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create loyalty reward', errorCodes.DATABASE_ERROR);
    }

    return data as LoyaltyReward;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to create loyalty reward', errorCodes.DATABASE_ERROR);
  }
}

export async function updateLoyaltyReward(id: string, rewardData: Partial<LoyaltyReward>): Promise<LoyaltyReward> {
  try {
    const currentReward = await getLoyaltyReward(id);

    if (!currentReward) {
      throw new AppError(404, 'Loyalty reward not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(loyaltyRewardsTable).update(rewardData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update loyalty reward', errorCodes.DATABASE_ERROR);
    }

    return data as LoyaltyReward;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update loyalty reward', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteLoyaltyReward(id: string): Promise<void> {
  try {
    const reward = await getLoyaltyReward(id);

    if (!reward) {
      throw new AppError(404, 'Loyalty reward not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(loyaltyRewardsTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete loyalty reward', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to delete loyalty reward', errorCodes.DATABASE_ERROR);
  }
}
