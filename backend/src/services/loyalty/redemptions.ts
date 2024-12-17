import { createClient } from '@supabase/supabase-js';
import { LoyaltyReward, LoyaltyTransaction, LoyaltyTransactionType, LoyaltyAccount, RewardRedemption, RewardRedemptionStatus } from '../../models/loyalty';
import { AppError, errorCodes } from '../../utils/errors';
import { v4 as uuidv4 } from 'uuid';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const loyaltyRewardsTable = 'loyaltyRewards';
const loyaltyTransactionsTable = 'loyaltyTransactions';
const loyaltyAccountsTable = 'loyaltyAccounts';
const rewardRedemptionsTable = 'rewardRedemptions';

export async function redeemReward(userId: string, rewardId: string): Promise<LoyaltyTransaction> {
  try {
    const reward = await getLoyaltyReward(rewardId);

    if (!reward) {
      throw new AppError(404, 'Loyalty reward not found', errorCodes.NOT_FOUND);
    }

    const account = await getLoyaltyAccount(userId);

    if (!account) {
      throw new AppError(404, 'Loyalty account not found', errorCodes.NOT_FOUND);
    }

    if (account.points < reward.pointsCost) {
      throw new AppError(400, 'Insufficient points to redeem reward', errorCodes.INSUFFICIENT_POINTS);
    }

    const updatedAccount = {
      points: account.points - reward.pointsCost,
      lastUpdated: new Date().toISOString()
    };

    const { data: updatedAccountData, error: accountError } = await supabase.from(loyaltyAccountsTable).update(updatedAccount).eq('userId', userId).select().single();

    if (accountError) {
      throw new AppError(500, 'Failed to update loyalty account', errorCodes.DATABASE_ERROR);
    }

    const transactionData: LoyaltyTransaction = {
      userId,
      rewardId,
      type: LoyaltyTransactionType.REDEEMED,
      points: -reward.pointsCost,
      description: `Redeemed reward ${reward.name}`,
      createdAt: new Date().toISOString()
    };

    const { data: transaction, error: transactionError } = await supabase.from(loyaltyTransactionsTable).insert([transactionData]).select().single();

    if (transactionError) {
      throw new AppError(500, 'Failed to create loyalty transaction', errorCodes.DATABASE_ERROR);
    }

    const redemptionId = uuidv4();

    const rewardRedemptionData: RewardRedemption = {
        id: redemptionId,
        userId,
        rewardId,
        transactionId: transaction.id,
        status: RewardRedemptionStatus.PENDING,
        createdAt: new Date().toISOString()
    };

    const { data: rewardRedemption, error: rewardRedemptionError } = await supabase.from(rewardRedemptionsTable).insert([rewardRedemptionData]).select().single();

    if (rewardRedemptionError) {
        throw new AppError(500, 'Failed to create reward redemption', errorCodes.DATABASE_ERROR);
    }

    const updatedTransactionData: LoyaltyTransaction = {
        ...transaction,
        redemptionId: redemptionId
    };

    const { data: updatedTransaction, error: updatedTransactionError } = await supabase.from(loyaltyTransactionsTable).update(updatedTransactionData).eq('id', transaction.id).select().single();

    if (updatedTransactionError) {
        throw new AppError(500, 'Failed to update loyalty transaction with redemption id', errorCodes.DATABASE_ERROR);
    }

    return updatedTransaction as LoyaltyTransaction;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to redeem reward', errorCodes.DATABASE_ERROR);
  }
}

async function getLoyaltyReward(rewardId: string): Promise<LoyaltyReward | null> {
  try {
    const { data, error } = await supabase.from(loyaltyRewardsTable).select('*').eq('id', rewardId).single();

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

async function getLoyaltyAccount(userId: string): Promise<LoyaltyAccount | null> {
  try {
    const { data, error } = await supabase.from(loyaltyAccountsTable).select('*').eq('userId', userId).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch loyalty account', errorCodes.DATABASE_ERROR);
    }

    return data as LoyaltyAccount;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch loyalty account', errorCodes.DATABASE_ERROR);
  }
}


export async function updateRewardRedemption(redemptionId: string, updates: Partial<RewardRedemption>): Promise<RewardRedemption | null> {
    try {
        const { data, error } = await supabase
            .from(rewardRedemptionsTable)
            .update(updates)
            .eq('id', redemptionId)
            .select()
            .single();

        if (error) {
            throw new AppError(500, 'Failed to update reward redemption', errorCodes.DATABASE_ERROR);
        }

        return data as RewardRedemption;
    } catch (err) {
        if (err instanceof AppError) {
            throw err;
        }
        throw new AppError(500, 'Failed to update reward redemption', errorCodes.DATABASE_ERROR);
    }
}


export async function getRewardRedemptions(options: { page?: number, limit?: number, status?: RewardRedemptionStatus, startDate?: Date, endDate?: Date }): Promise<{ redemptions: RewardRedemption[], total: number }> {
    try {
        let query = supabase.from(rewardRedemptionsTable).select('*', { count: 'exact' });

        if (options.status) {
            query = query.eq('status', options.status);
        }

        if (options.startDate) {
            query = query.gte('createdAt', options.startDate.toISOString());
        }

        if (options.endDate) {
            query = query.lte('createdAt', options.endDate.toISOString());
        }


        const { data, error, count } = await query
            .range(
                (options.page ? options.page - 1 : 0) * (options.limit || 10),
                (options.page ? options.page - 1 : 0) * (options.limit || 10) + (options.limit || 10) - 1
            );


        if (error) {
            throw new AppError(500, 'Failed to fetch reward redemptions', errorCodes.DATABASE_ERROR);
        }

        return {
            redemptions: data as RewardRedemption[],
            total: count || 0
        };
    } catch (err) {
        if (err instanceof AppError) {
            throw err;
        }
        throw new AppError(500, 'Failed to fetch reward redemptions', errorCodes.DATABASE_ERROR);
    }
}
