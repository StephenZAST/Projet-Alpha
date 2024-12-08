import { db } from './firebase';
import { LoyaltyAccount } from '../models/loyalty';
import { NotificationService } from './notifications';
import * as Points from './loyalty/points';
import * as Rewards from './loyalty/rewards';
import * as Redemptions from './loyalty/redemptions';
import * as Tiers from './loyalty/tiers';
import * as Program from './loyalty/program';

export class LoyaltyService {
  private readonly loyaltyRef = db.collection('loyalty_accounts');
  private notificationService = new NotificationService();

  // Points
  calculateTier = Points.calculateTier;
  addPoints = Points.addPoints;
  getPointsHistory = Points.getPointsHistory;
  getUserPoints = Points.getUserPoints;
  adjustUserPoints = Points.adjustUserPoints;

  // Rewards
  createReward = Rewards.createReward;
  updateReward = Rewards.updateReward;
  deleteReward = Rewards.deleteReward;
  getRewards = Rewards.getRewards;
  getRewardById = Rewards.getRewardById;
  getAvailableRewards = Rewards.getAvailableRewards;

  // Redemptions
  redeemReward = Redemptions.redeemReward;
  verifyAndClaimPhysicalReward = Redemptions.verifyAndClaimPhysicalReward;
  getPendingPhysicalRewards = Redemptions.getPendingPhysicalRewards;
  getRewardRedemptions = Redemptions.getRewardRedemptions;
  updateRedemptionStatus = Redemptions.updateRedemptionStatus;

  // Tiers
  updateLoyaltyTier = Tiers.updateLoyaltyTier;
  getLoyaltyTiers = Tiers.getLoyaltyTiers;

  // Program
  createLoyaltyProgram = Program.createLoyaltyProgram;
  getLoyaltyProgram = Program.getLoyaltyProgram;
  getAllLoyaltyPrograms = Program.getAllLoyaltyPrograms;
  getLoyaltyProgramById = Program.getLoyaltyProgramById;
  updateLoyaltyProgram = Program.updateLoyaltyProgram;
  deleteLoyaltyProgram = Program.deleteLoyaltyProgram;

  async getLoyaltyAccount(userId: string): Promise<LoyaltyAccount | null> {
    const doc = await this.loyaltyRef.doc(userId).get();
    return doc.exists ? (doc.data() as LoyaltyAccount) : null;
  }
}
