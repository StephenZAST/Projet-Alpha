import { db } from '../firebase';
import {
  RewardRedemption,
  RewardStatus,
} from '../../models/loyalty';
import { UserAddress } from '../../models/user';
import { AppError, errorCodes } from '../../utils/errors';
import { NotificationService } from '../notifications';

const redemptionsRef = db.collection('reward_redemptions');
const rewardsRef = db.collection('rewards');
const loyaltyRef = db.collection('loyalty_accounts');
const notificationService = new NotificationService();

export async function redeemReward(userId: string, rewardId: string, shippingAddress: UserAddress): Promise<string> {
  const rewardRef = rewardsRef.doc(rewardId);
  const accountRef = loyaltyRef.doc(userId);

  try {
    let redemptionId: string;

    await db.runTransaction(async (transaction) => {
      const rewardDoc = await transaction.get(rewardRef);
      const accountDoc = await transaction.get(accountRef);

      if (!rewardDoc.exists || !accountDoc.exists) {
        throw new AppError(404, 'Reward or account not found', errorCodes.NOT_FOUND);
      }

      const reward = rewardDoc.data() as { type: string; pointsCost: number };
      const account = accountDoc.data() as { points: number };

      if (account.points < reward.pointsCost) {
        throw new AppError(400, 'Insufficient points', errorCodes.INSUFFICIENT_POINTS);
      }

      // Generate unique verification code
      const verificationCode = Math.random().toString(36).substring(2, 8).toUpperCase();

      // Create redemption record
      const redemptionRef = redemptionsRef.doc();
      redemptionId = redemptionRef.id;

      const redemption: RewardRedemption = {
        id: redemptionId,
        userId,
        rewardId,
        redemptionDate: new Date(),
        status: reward.type === 'physical' ? RewardStatus.REDEEMED : RewardStatus.CLAIMED,
        verificationCode,
        shippingAddress: {
          ...shippingAddress,
          phoneNumber: shippingAddress.phoneNumber || '' // Provide a default value for phoneNumber
        }
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

export async function verifyAndClaimPhysicalReward(
  redemptionId: string,
  adminId: string,
  notes?: string
): Promise<boolean> {
  const redemptionRef = redemptionsRef.doc(redemptionId);

  try {
    await db.runTransaction(async (transaction) => {
      const doc = await transaction.get(redemptionRef);
      if (!doc.exists) {
        throw new AppError(404, 'Redemption not found', errorCodes.NOT_FOUND);
      }

      const redemption = doc.data() as RewardRedemption;
      if (redemption.status !== RewardStatus.REDEEMED) {
        throw new AppError(400, 'Reward already claimed or expired', errorCodes.VALIDATION_ERROR);
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

export async function getPendingPhysicalRewards(): Promise<RewardRedemption[]> {
  const snapshot = await redemptionsRef
    .where('status', '==', RewardStatus.REDEEMED)
    .get();

  return snapshot.docs.map(doc => doc.data() as RewardRedemption);
}

export async function getRewardRedemptions(options: {
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

  let query = redemptionsRef.orderBy('redemptionDate', 'desc');

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
    redemptionsRef.count().get()
  ]);

  return {
    redemptions: snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as RewardRedemption)),
    total: countSnapshot.data().count
  };
}

export async function updateRedemptionStatus(
  redemptionId: string,
  status: RewardStatus,
  notes?: string
): Promise<RewardRedemption> {
  const redemptionRef = redemptionsRef.doc(redemptionId);
  const doc = await redemptionRef.get();

  if (!doc.exists) {
    throw new AppError(404, 'Redemption not found', errorCodes.NOT_FOUND);
  }

  const { userId, rewardId, redemptionDate, verificationCode, shippingAddress } = doc.data() as RewardRedemption;

  await redemptionRef.update({
    status,
    notes,
    updatedAt: new Date()
  });

  // Notify user about redemption status change
  await notificationService.sendRedemptionStatusUpdate(userId, status);

  return {
    id: redemptionId,
    userId,
    rewardId,
    redemptionDate,
    status,
    verificationCode,
    shippingAddress,
    notes,
    updatedAt: new Date()
  };
}
