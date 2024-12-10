import { db } from '../firebase';
import { Bill } from '../../models/bill';
import { Reward } from '../../models/loyalty';
import { SubscriptionPlan } from '../../models/subscription';
import { AppError, errorCodes } from '../../utils/errors';
import { Timestamp } from 'firebase-admin/firestore';

export class LoyaltyAndSubscriptionService {
  async applyLoyaltyPointsToBill(billId: string, userId: string, rewardId: string): Promise<Bill> {
    try {
      const bill = await db.collection('bills').doc(billId).get();
      if (!bill.exists) {
        throw new AppError(404, 'Bill not found', errorCodes.BILL_NOT_FOUND);
      }

      const user = await db.collection('users').doc(userId).get();
      if (!user.exists) {
        throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
      }

      const reward = await db.collection('rewards').doc(rewardId).get();
      if (!reward.exists) {
        throw new AppError(404, 'Reward not found', errorCodes.REWARD_NOT_FOUND);
      }

      const rewardData = reward.data() as Reward;
      const userLoyaltyPoints = user.data()?.loyaltyPoints || 0;

      if (rewardData.pointsRequired !== undefined && userLoyaltyPoints < rewardData.pointsRequired) {
        throw new AppError(400, 'Insufficient loyalty points', errorCodes.INSUFFICIENT_POINTS);
      }

      const discountAmount = rewardData.discountAmount || 0;
      const updatedTotalAmount = (bill.data() as Bill).totalAmount - discountAmount;

      await db.collection('bills').doc(billId).update({ totalAmount: updatedTotalAmount, updatedAt: Timestamp.now() });

      if (rewardData.pointsRequired !== undefined) {
        await db.collection('users').doc(userId).update({
          loyaltyPoints: userLoyaltyPoints - (rewardData.pointsRequired || 0),
          updatedAt: Timestamp.now()
        });
      }

      const updatedBill = await db.collection('bills').doc(billId).get();
      return { id: updatedBill.id, ...updatedBill.data() } as Bill;
    } catch (error) {
      console.error('Error applying loyalty points to bill:', error);
      throw new AppError(500, 'Failed to apply loyalty points', errorCodes.LOYALTY_POINTS_UPDATE_FAILED);
    }
  }

  async applySubscriptionDiscountToBill(billId: string, userId: string, planId: string): Promise<Bill> {
    try {
      const bill = await db.collection('bills').doc(billId).get();
      if (!bill.exists) {
        throw new AppError(404, 'Bill not found', errorCodes.BILL_NOT_FOUND);
      }

      const user = await db.collection('users').doc(userId).get();
      if (!user.exists) {
        throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
      }

      const plan = await db.collection('subscriptionPlans').doc(planId).get();
      if (!plan.exists) {
        throw new AppError(404, 'Subscription plan not found', errorCodes.SUBSCRIPTION_PLAN_NOT_FOUND);
      }

      const planData = plan.data() as SubscriptionPlan;
      const discountPercentage = planData.discountPercentage || 0;
      const discountAmount = ((bill.data() as Bill).totalAmount * discountPercentage) / 100;
      const updatedTotalAmount = (bill.data() as Bill).totalAmount - discountAmount;

      await db.collection('bills').doc(billId).update({ totalAmount: updatedTotalAmount, updatedAt: Timestamp.now() });

      const updatedBill = await db.collection('bills').doc(billId).get();
      return { id: updatedBill.id, ...updatedBill.data() } as Bill;
    } catch (error) {
      console.error('Error applying subscription discount to bill:', error);
      throw new AppError(500, 'Failed to apply subscription discount', errorCodes.LOYALTY_POINTS_UPDATE_FAILED);
    }
  }
}
