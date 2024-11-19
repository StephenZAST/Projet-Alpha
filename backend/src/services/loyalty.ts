import { db } from './firebase';
import { 
  LoyaltyAccount, 
  LoyaltyTier, 
  Reward, 
  RewardRedemption, 
  RewardStatus, 
  RewardType,
  PointsTransaction,
  LoyaltyTierConfig
} from '../models/loyalty';
import { NotificationService } from './notifications';
import { AppError } from '../utils/errors';

export class LoyaltyService {
  private readonly loyaltyRef = db.collection('loyalty_accounts');
  private readonly rewardsRef = db.collection('rewards');
  private readonly redemptionsRef = db.collection('reward_redemptions');
  private readonly pointsHistoryRef = db.collection('points_history');
  private readonly tiersRef = db.collection('loyalty_tiers');
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

  async redeemReward(userId: string, rewardId: string, shippingAddress: any): Promise<string> {
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

  async getAvailableRewards(userId: string, p0: { type: string; category: string; status: string; }): Promise<Reward[]> {
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

  async getPointsHistory(
    userId: string,
    page: number = 1,
    limit: number = 10
  ): Promise<{ transactions: PointsTransaction[]; total: number }> {
    const offset = (page - 1) * limit;
    const query = this.pointsHistoryRef
      .where('userId', '==', userId)
      .orderBy('timestamp', 'desc')
      .limit(limit)
      .offset(offset);

    const [snapshot, countSnapshot] = await Promise.all([
      query.get(),
      this.pointsHistoryRef.where('userId', '==', userId).count().get()
    ]);

    return {
      transactions: snapshot.docs.map(doc => doc.data() as PointsTransaction),
      total: countSnapshot.data().count
    };
  }

  async createReward(rewardData: Partial<Reward>): Promise<Reward> {
    const reward: Reward = {
      ...rewardData,
      createdAt: new Date(),
      isActive: true,
      redemptionCount: 0
    } as Reward;

    const rewardRef = this.rewardsRef.doc();
    await rewardRef.set(reward);

    return {
      id: rewardRef.id,
      ...reward
    };
  }

  async updateLoyaltyTier(
    tierId: string,
    tierData: Partial<LoyaltyTierConfig>
  ): Promise<LoyaltyTierConfig> {
    const tierRef = this.tiersRef.doc(tierId);
    const doc = await tierRef.get();

    if (!doc.exists) {
      throw new AppError('Tier not found', 404);
    }

    const updatedTier = {
      ...doc.data(),
      ...tierData,
      updatedAt: new Date()
    } as LoyaltyTierConfig;

    await tierRef.update(updatedTier);
    return updatedTier;
  }

  async getLoyaltyTiers(): Promise<LoyaltyTierConfig[]> {
    const snapshot = await this.tiersRef.orderBy('pointsThreshold', 'asc').get();
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as LoyaltyTierConfig));
  }

  async getRewardRedemptions(options: {
    page?: number;
    limit?: number;
    status?: string;
    startDate?: Date;
    endDate?: Date;
  }): Promise<{ redemptions: RewardRedemption[]; total: number }> {
    const {
      page = 1,
      limit = 10,
      status,
      startDate,
      endDate
    } = options;

    let query = this.redemptionsRef.orderBy('redemptionDate', 'desc');

    if (status) {
      query = query.where('status', '==', status);
    }

    if (startDate) {
      query = query.where('redemptionDate', '>=', startDate);
    }

    if (endDate) {
      query = query.where('redemptionDate', '<=', endDate);
    }

    const offset = (page - 1) * limit;
    query = query.limit(limit).offset(offset);

    const [snapshot, countSnapshot] = await Promise.all([
      query.get(),
      this.redemptionsRef.count().get()
    ]);

    return {
      redemptions: snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      } as RewardRedemption)),
      total: countSnapshot.data().count
    };
  }

  async updateRedemptionStatus(
    redemptionId: string,
    status: RewardStatus,
    notes?: string
  ): Promise<RewardRedemption> {
    const redemptionRef = this.redemptionsRef.doc(redemptionId);
    const doc = await redemptionRef.get();

    if (!doc.exists) {
      throw new AppError('Redemption not found', 404);
    }

    const updatedRedemption = {
      ...doc.data(),
      status,
      notes,
      updatedAt: new Date()
    } as RewardRedemption;

    await redemptionRef.update(updatedRedemption);

    // Notify user about redemption status change
    const userId = updatedRedemption.userId;
    await this.notificationService.sendRedemptionStatusUpdate(userId, status);

    return updatedRedemption;
  }
}