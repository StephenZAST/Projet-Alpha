import supabase from '../../config/supabase';
import { AppError, errorCodes } from '../../utils/errors';

export enum LoyaltyTier {
  BRONZE = 'BRONZE',    // 0-1000 points
  SILVER = 'SILVER',     // 1001-5000 points
  GOLD = 'GOLD',
  PLATINUM = 'PLATINUM'
}

export interface LoyaltyAccount {
  userId: string;
  points: number;
  lifetimePoints: number;
  tier: LoyaltyTier;
  lastUpdated: string;
}

function calculateLoyaltyTier(points: number): LoyaltyTier {
  if (points <= 1000) {
    return LoyaltyTier.BRONZE;
  } else if (points <= 5000) {
    return LoyaltyTier.SILVER;
  }
  // Expand with more tiers if needed
  throw new Error("Points exceed defined tiers");
}

// Use Supabase to store loyalty account data
const loyaltyAccountsTable = 'loyaltyAccounts';

// Function to get loyalty account data
export async function getLoyaltyAccount(userId: string): Promise<LoyaltyAccount | null> {
  const { data, error } = await supabase.from(loyaltyAccountsTable).select('*').eq('userId', userId).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch loyalty account', 'INTERNAL_SERVER_ERROR');
  }

  return data as LoyaltyAccount;
}

// Function to create loyalty account
export async function createLoyaltyAccount(accountData: LoyaltyAccount): Promise<LoyaltyAccount> {
  const { data, error } = await supabase.from(loyaltyAccountsTable).insert([accountData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create loyalty account', 'INTERNAL_SERVER_ERROR');
  }

  return data as LoyaltyAccount;
}

// Function to update loyalty account
export async function updateLoyaltyAccount(userId: string, accountData: Partial<LoyaltyAccount>): Promise<LoyaltyAccount> {
  const currentAccount = await getLoyaltyAccount(userId);

  if (!currentAccount) {
    throw new AppError(404, 'Loyalty account not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(loyaltyAccountsTable).update(accountData).eq('userId', userId).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update loyalty account', 'INTERNAL_SERVER_ERROR');
  }

  return data as LoyaltyAccount;
}

// Function to delete loyalty account
export async function deleteLoyaltyAccount(userId: string): Promise<void> {
  const account = await getLoyaltyAccount(userId);

  if (!account) {
    throw new AppError(404, 'Loyalty account not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(loyaltyAccountsTable).delete().eq('userId', userId);

  if (error) {
    throw new AppError(500, 'Failed to delete loyalty account', 'INTERNAL_SERVER_ERROR');
  }
}
