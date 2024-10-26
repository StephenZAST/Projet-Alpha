
import { db } from './firebase';
import { LoyaltyAccount, LoyaltyTier, Reward, RewardRedemption, RewardStatus, RewardType } from '../models/loyalty';
import { NotificationService } from './notifications';

export class LoyaltyService {
  private readonly loyaltyRef = db.collection('loyalty_accounts');
  private readonly rewardsRef = db.collection('rewards');
  private readonly redemptionsRef = db.collection('reward_redemptions');
  private notificationService = new NotificationService();

  async calculateTier(points: number): Promise<LoyaltyTier> {
    if (points >= 10001) return LoyaltyTier.PLATINUM;
    if (points >= 5001) return LoyaltyTier.GOLD;
    if (points >= 1001) return LoyaltyTier.SILVER;
    return LoyaltyTier.BRONZE;
  }

  async addPoints(userId: string, points: number, reason: string): Promise<LoyaltyAccount> {
    const accountRef = this.loyaltyRef.doc(userId);
    const account = await accountRef.get();

    let updatedAccount: LoyaltyAccount;

    await db.runTransaction(async (transaction) => {
      if (!account.exists) {
        updatedAccount = {
          userId,
          points: points,
          lifetimePoints: points,
          tier: await this.calculateTier(points),
          lastUpdated: new Date()
        };
        transaction.set(accountRef, updatedAccount);
      } else {
        const currentAccount = account.data() as LoyaltyAccount;
        const newPoints = currentAccount.points + points;
        const newLifetimePoints = currentAccount.lifetimePoints + points;
        const newTier = await this.calculateTier(newLifetimePoints);

        updatedAccount = {
          ...currentAccount,
          points: newPoints,
          lifetimePoints: newLifetimePoints,
          tier: newTier,
          lastUpdated: new Date()
        };
              transaction.update(accountRef, {
                points: updatedAccount.points,
                lifetimePoints: updatedAccount.lifetimePoints,
                tier: updatedAccount.tier,
                lastUpdated: updatedAccount.lastUpdated
              });
      }
    });

    // Send notification about points earned
    await this.notificationService.sendLoyaltyPointsReminder(userId, points);

    return updatedAccount!;
  }

  async redeemReward(userId: string, rewardId: string): Promise<string> {
    const rewardRef = this.rewardsRef.doc(rewardId);
    const accountRef = this.loyaltyRef.doc(userId);

    try {
      let redemptionId: string;
      
      await db.runTransaction(async (transaction) => {
        const rewardDoc = await transaction.get(rewardRef);
        const accountDoc = await transaction.get(accountRef);

        if (!rewardDoc.exists || !accountDoc.exists) {
          throw new Error('Reward or account not found');
        }

        const reward = rewardDoc.data() as Reward;
        const account = accountDoc.data() as LoyaltyAccount;

        if (account.points < reward.pointsCost) {
          throw new Error('Insufficient points');
        }

        // Generate unique verification code
        const verificationCode = Math.random().toString(36).substring(2, 8).toUpperCase();

        // Create redemption record
        const redemptionRef = this.redemptionsRef.doc();
        redemptionId = redemptionRef.id;

        const redemption: RewardRedemption = {
          id: redemptionId,
          userId,
          rewardId,
          redemptionDate: new Date(),
          status: reward.type === RewardType.GIFT ? RewardStatus.REDEEMED : RewardStatus.CLAIMED,
          verificationCode,
        };

        // Update points balance
        transaction.update(accountRef, {
          points: account.points - reward.pointsCost,
          lastUpdated: new Date()
        });

        // Save redemption record
        transaction.set(redemptionRef, redemption);
      });

      return redemptionId!;
    } catch (error) {
      console.error('Error redeeming reward:', error);
      throw error;
    }
  }

  async verifyAndClaimPhysicalReward(
    redemptionId: string,
    adminId: string,
    notes?: string
  ): Promise<boolean> {
    const redemptionRef = this.redemptionsRef.doc(redemptionId);

    try {
      await db.runTransaction(async (transaction) => {
        const doc = await transaction.get(redemptionRef);
        if (!doc.exists) {
          throw new Error('Redemption not found');
        }

        const redemption = doc.data() as RewardRedemption;
        if (redemption.status !== RewardStatus.REDEEMED) {
          throw new Error('Reward already claimed or expired');
        }

        transaction.update(redemptionRef, {
          status: RewardStatus.CLAIMED,
          claimedDate: new Date(),
          claimedByAdminId: adminId,
          notes
        });
      });

      return true;
    } catch (error) {
      console.error('Error claiming reward:', error);
      return false;
    }
  }

  async getPendingPhysicalRewards(): Promise<RewardRedemption[]> {
    const snapshot = await this.redemptionsRef
      .where('status', '==', RewardStatus.REDEEMED)
      .get();

    return snapshot.docs.map(doc => doc.data() as RewardRedemption);
  }

  async getAvailableRewards(userId: string): Promise<Reward[]> {
    const accountDoc = await this.loyaltyRef.doc(userId).get();
    if (!accountDoc.exists) {
      return [];
    }

    const account = accountDoc.data() as LoyaltyAccount;
    const rewardsSnapshot = await this.rewardsRef
      .where('isActive', '==', true)
      .where('pointsCost', '<=', account.points)
      .get();

    return rewardsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Reward));
  }

  async getLoyaltyAccount(userId: string): Promise<LoyaltyAccount | null> {
    const doc = await this.loyaltyRef.doc(userId).get();
    return doc.exists ? (doc.data() as LoyaltyAccount) : null;
  }
}