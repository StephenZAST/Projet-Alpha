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

export async function getRewards(options: { page?: number, limit?: number, status?: string, startDate?: Date, endDate?: Date }): Promise<{ rewards: LoyaltyReward[], total: number }> {
    try {
        const page = options.page || 1;
        const limit = options.limit || 10;
        const status = options.status;
        const startDate = options.startDate;
        const endDate = options.endDate;

        let query = supabase.from(loyaltyRewardsTable).select('*', { count: 'exact' });

        if (status) {
            query = query.eq('status', status);
        }

        if (startDate) {
            query = query.gte('createdAt', startDate.toISOString());
        }

        if (endDate) {
            query = query.lte('createdAt', endDate.toISOString());
        }


        const { data, error, count } = await query
            .range((page - 1) * limit, page * limit - 1);


        if (error) {
            throw new AppError(500, 'Failed to fetch loyalty rewards', errorCodes.DATABASE_ERROR);
        }

        return { rewards: data as LoyaltyReward[], total: count || 0 };
    } catch (err) {
        if (err instanceof AppError) {
            throw err;
        }
        throw new AppError(500, 'Failed to fetch loyalty rewards', errorCodes.DATABASE_ERROR);
    }
}

export async function getRewardById(id: string): Promise<LoyaltyReward | null> {
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

export async function getPendingPhysicalRewards(): Promise<LoyaltyReward[]> {
  try {
    const { data, error } = await supabase
      .from(loyaltyRewardsTable)
      .select('*')
      .eq('type', 'physical')
      .eq('status', 'pending');

    if (error) {
      throw new AppError(500, 'Failed to fetch pending physical rewards', errorCodes.DATABASE_ERROR);
    }

    return data as LoyaltyReward[];
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch pending physical rewards', errorCodes.DATABASE_ERROR);
  }
}

export async function getAvailableRewards(userId: string, options: { type?: string, category?: string, status?: string }): Promise<LoyaltyReward[]> {
    try {
        let query = supabase.from(loyaltyRewardsTable).select('*');

        if (options.type) {
            query = query.eq('type', options.type);
        }

        if (options.category) {
            query = query.eq('category', options.category);
        }

         if (options.status) {
            query = query.eq('status', options.status);
        }

        const { data, error } = await query;

        if (error) {
            throw new AppError(500, 'Failed to fetch available rewards', errorCodes.DATABASE_ERROR);
        }

        return data as LoyaltyReward[];
    } catch (err) {
        if (err instanceof AppError) {
            throw err;
        }
        throw new AppError(500, 'Failed to fetch available rewards', errorCodes.DATABASE_ERROR);
    }
}
