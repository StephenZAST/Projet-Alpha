import { getLoyaltyAccount, createLoyaltyAccount, updateLoyaltyAccount, deleteLoyaltyAccount, createLoyaltyTransaction, getLoyaltyTransaction, updateLoyaltyTransaction, deleteLoyaltyTransaction } from './loyalty/points';
import { getLoyaltyProgram, createLoyaltyProgram, updateLoyaltyProgram, deleteLoyaltyProgram } from './loyalty/program';
import { redeemReward } from './loyalty/redemptions';
import { getLoyaltyReward, createLoyaltyReward, updateLoyaltyReward, deleteLoyaltyReward } from './loyalty/rewards';
import { updateLoyaltyTier, getLoyaltyTiers } from './loyalty/tiers';
import { LoyaltyAccount, LoyaltyTier, LoyaltyTransaction, LoyaltyTransactionType, LoyaltyProgram, LoyaltyReward, LoyaltyTierConfig, LoyaltyTierDefinition } from '../models/loyalty';

export class LoyaltyService {
  async getLoyaltyAccount(userId: string): Promise<LoyaltyAccount | null> {
    return getLoyaltyAccount(userId);
  }

  async createLoyaltyAccount(accountData: LoyaltyAccount): Promise<LoyaltyAccount> {
    return createLoyaltyAccount(accountData);
  }

  async updateLoyaltyAccount(userId: string, accountData: Partial<LoyaltyAccount>): Promise<LoyaltyAccount> {
    return updateLoyaltyAccount(userId, accountData);
  }

  async deleteLoyaltyAccount(userId: string): Promise<void> {
    return deleteLoyaltyAccount(userId);
  }

  async createLoyaltyTransaction(transactionData: LoyaltyTransaction): Promise<LoyaltyTransaction> {
    return createLoyaltyTransaction(transactionData);
  }

  async getLoyaltyTransaction(id: string): Promise<LoyaltyTransaction | null> {
    return getLoyaltyTransaction(id);
  }

  async updateLoyaltyTransaction(id: string, transactionData: Partial<LoyaltyTransaction>): Promise<LoyaltyTransaction> {
    return updateLoyaltyTransaction(id, transactionData);
  }

  async deleteLoyaltyTransaction(id: string): Promise<void> {
    return deleteLoyaltyTransaction(id);
  }

  async getLoyaltyProgram(id: string): Promise<LoyaltyProgram | null> {
    return getLoyaltyProgram(id);
  }

  async createLoyaltyProgram(programData: LoyaltyProgram): Promise<LoyaltyProgram> {
    return createLoyaltyProgram(programData);
  }

  async updateLoyaltyProgram(id: string, programData: Partial<LoyaltyProgram>): Promise<LoyaltyProgram> {
    return updateLoyaltyProgram(id, programData);
  }

  async deleteLoyaltyProgram(id: string): Promise<void> {
    return deleteLoyaltyProgram(id);
  }

  async redeemReward(userId: string, rewardId: string): Promise<LoyaltyTransaction> {
    return redeemReward(userId, rewardId);
  }

  async getLoyaltyReward(id: string): Promise<LoyaltyReward | null> {
    return getLoyaltyReward(id);
  }

  async createLoyaltyReward(rewardData: LoyaltyReward): Promise<LoyaltyReward> {
    return createLoyaltyReward(rewardData);
  }

  async updateLoyaltyReward(id: string, rewardData: Partial<LoyaltyReward>): Promise<LoyaltyReward> {
    return updateLoyaltyReward(id, rewardData);
  }

  async deleteLoyaltyReward(id: string): Promise<void> {
    return deleteLoyaltyReward(id);
  }

  async updateLoyaltyTier(tierId: string, tierData: Partial<LoyaltyTierConfig>): Promise<LoyaltyTierConfig> {
    return updateLoyaltyTier(tierId, tierData);
  }

  async getLoyaltyTiers(): Promise<LoyaltyTierConfig[]> {
    return getLoyaltyTiers();
  }
}

export const loyaltyService = new LoyaltyService();
