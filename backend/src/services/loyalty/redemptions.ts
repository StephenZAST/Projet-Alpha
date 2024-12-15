import { createClient } from '@supabase/supabase-js';
import { LoyaltyReward, LoyaltyTransaction, LoyaltyTransactionType, LoyaltyAccount } from '../../models/loyalty';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const loyaltyRewardsTable = 'loyaltyRewards';
const loyaltyTransactionsTable = 'loyaltyTransactions';
const loyaltyAccountsTable = 'loyaltyAccounts';

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

    return transaction as LoyaltyTransaction;
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
