import { createClient } from '@supabase/supabase-js';
import { LoyaltyAccount, LoyaltyTier, LoyaltyTransaction, LoyaltyTransactionType } from '../../models/loyalty';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const loyaltyAccountsTable = 'loyaltyAccounts';
const loyaltyTransactionsTable = 'loyaltyTransactions';

export async function getLoyaltyAccount(userId: string): Promise<LoyaltyAccount | null> {
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

export async function createLoyaltyAccount(accountData: LoyaltyAccount): Promise<LoyaltyAccount> {
  try {
    const { data, error } = await supabase.from(loyaltyAccountsTable).insert([accountData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create loyalty account', errorCodes.DATABASE_ERROR);
    }

    return data as LoyaltyAccount;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to create loyalty account', errorCodes.DATABASE_ERROR);
  }
}

export async function updateLoyaltyAccount(userId: string, accountData: Partial<LoyaltyAccount>): Promise<LoyaltyAccount> {
  try {
    const currentAccount = await getLoyaltyAccount(userId);

    if (!currentAccount) {
      throw new AppError(404, 'Loyalty account not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(loyaltyAccountsTable).update(accountData).eq('userId', userId).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update loyalty account', errorCodes.DATABASE_ERROR);
    }

    return data as LoyaltyAccount;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update loyalty account', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteLoyaltyAccount(userId: string): Promise<void> {
  try {
    const account = await getLoyaltyAccount(userId);

    if (!account) {
      throw new AppError(404, 'Loyalty account not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(loyaltyAccountsTable).delete().eq('userId', userId);

    if (error) {
      throw new AppError(500, 'Failed to delete loyalty account', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to delete loyalty account', errorCodes.DATABASE_ERROR);
  }
}

export async function createLoyaltyTransaction(transactionData: LoyaltyTransaction): Promise<LoyaltyTransaction> {
  try {
    const { data, error } = await supabase.from(loyaltyTransactionsTable).insert([transactionData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create loyalty transaction', errorCodes.DATABASE_ERROR);
    }

    return data as LoyaltyTransaction;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to create loyalty transaction', errorCodes.DATABASE_ERROR);
  }
}

export async function getLoyaltyTransaction(id: string): Promise<LoyaltyTransaction | null> {
  try {
    const { data, error } = await supabase.from(loyaltyTransactionsTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch loyalty transaction', errorCodes.DATABASE_ERROR);
    }

    return data as LoyaltyTransaction;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch loyalty transaction', errorCodes.DATABASE_ERROR);
  }
}

export async function updateLoyaltyTransaction(id: string, transactionData: Partial<LoyaltyTransaction>): Promise<LoyaltyTransaction> {
  try {
    const currentTransaction = await getLoyaltyTransaction(id);

    if (!currentTransaction) {
      throw new AppError(404, 'Loyalty transaction not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(loyaltyTransactionsTable).update(transactionData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update loyalty transaction', errorCodes.DATABASE_ERROR);
    }

    return data as LoyaltyTransaction;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update loyalty transaction', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteLoyaltyTransaction(id: string): Promise<void> {
  try {
    const transaction = await getLoyaltyTransaction(id);

    if (!transaction) {
      throw new AppError(404, 'Loyalty transaction not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(loyaltyTransactionsTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete loyalty transaction', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to delete loyalty transaction', errorCodes.DATABASE_ERROR);
  }
}

export async function addPoints(userId: string, points: number, reason: string): Promise<LoyaltyAccount> {
    try {
      const account = await getLoyaltyAccount(userId);

      if (!account) {
        throw new AppError(404, 'Loyalty account not found', errorCodes.NOT_FOUND);
      }

      const updatedPoints = account.points + points;

      const { data, error } = await supabase
        .from(loyaltyAccountsTable)
        .update({ points: updatedPoints, lastUpdated: new Date().toISOString() })
        .eq('userId', userId)
        .select()
        .single();

      if (error) {
        throw new AppError(500, 'Failed to add points to loyalty account', errorCodes.DATABASE_ERROR);
      }

      const transactionData: LoyaltyTransaction = {
        userId,
        type: LoyaltyTransactionType.EARNED,
        points,
        description: reason,
        createdAt: new Date().toISOString()
      };

      await createLoyaltyTransaction(transactionData);

      return data as LoyaltyAccount;
    } catch (err) {
      if (err instanceof AppError) {
        throw err;
      }
      throw new AppError(500, 'Failed to add points to loyalty account', errorCodes.DATABASE_ERROR);
    }
  }
