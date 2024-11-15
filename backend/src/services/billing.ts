import { db } from './firebase';
import { Bill, BillStatus } from '../models/billing';
import { LoyaltyTransaction, LoyaltyReward } from '../models/loyalty';
import { Subscription, SubscriptionType } from '../models/subscription';
import { AppError, errorCodes } from '../utils/errors';

// Services de facturation
export async function createBill(bill: Bill): Promise<Bill> {
  try {
    const billRef = await db.collection('bills').add({
      ...bill,
      creationDate: new Date(),
      status: BillStatus.PENDING,
      lastUpdated: new Date()
    });
    
    return { ...bill, id: billRef.id };
  } catch (error) {
    console.error('Error creating bill:', error);
    throw new AppError(errorCodes.BILL_CREATION_FAILED, 'Failed to create bill');
  }
}

export async function getBillById(billId: string): Promise<Bill | null> {
  try {
    const billDoc = await db.collection('bills').doc(billId).get();
    
    if (!billDoc.exists) {
      return null;
    }
    
    return { id: billDoc.id, ...billDoc.data() } as Bill;
  } catch (error) {
    console.error('Error fetching bill:', error);
    throw new AppError(errorCodes.BILL_FETCH_FAILED, 'Failed to fetch bill');
  }
}

export async function getBillsByUser(userId: string): Promise<Bill[]> {
  try {
    const billsSnapshot = await db.collection('bills')
      .where('userId', '==', userId)
      .orderBy('creationDate', 'desc')
      .get();
    
    return billsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Bill));
  } catch (error) {
    console.error('Error fetching user bills:', error);
    throw new AppError(errorCodes.USER_BILLS_FETCH_FAILED, 'Failed to fetch user bills');
  }
}

export async function updateBillStatus(billId: string, status: BillStatus): Promise<boolean> {
  try {
    await db.collection('bills').doc(billId).update({
      status,
      lastUpdated: new Date()
    });
    
    return true;
  } catch (error) {
    console.error('Error updating bill status:', error);
    throw new AppError(errorCodes.BILL_UPDATE_FAILED, 'Failed to update bill status');
  }
}

// Services de fidélité
export async function getLoyaltyPoints(userId: string): Promise<number> {
  try {
    const userDoc = await db.collection('users').doc(userId).get();
    
    if (!userDoc.exists) {
      throw new AppError(errorCodes.USER_NOT_FOUND, 'User not found');
    }
    
    const userData = userDoc.data();
    return userData?.loyaltyPoints || 0;
  } catch (error) {
    console.error('Error fetching loyalty points:', error);
    throw new AppError(errorCodes.LOYALTY_POINTS_FETCH_FAILED, 'Failed to fetch loyalty points');
  }
}

export async function addLoyaltyPoints(
  userId: string,
  points: number,
  reason: string
): Promise<number> {
  try {
    const userRef = db.collection('users').doc(userId);
    
    await db.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);
      if (!userDoc.exists) {
        throw new AppError(errorCodes.USER_NOT_FOUND, 'User not found');
      }
      
      const currentPoints = userDoc.data()?.loyaltyPoints || 0;
      const newPoints = currentPoints + points;
      
      transaction.update(userRef, { loyaltyPoints: newPoints });
      
      // Enregistrer la transaction de points
      const loyaltyTransaction: LoyaltyTransaction = {
        userId,
        points,
        type: points > 0 ? 'EARNED' : 'SPENT',
        reason,
        date: new Date()
      };
      
      transaction.create(
        db.collection('loyaltyTransactions').doc(),
        loyaltyTransaction
      );
    });
    
    return points;
  } catch (error) {
    console.error('Error adding loyalty points:', error);
    throw new AppError(errorCodes.LOYALTY_POINTS_UPDATE_FAILED, 'Failed to add loyalty points');
  }
}

export async function redeemLoyaltyPoints(
  userId: string,
  rewardId: string
): Promise<LoyaltyReward> {
  try {
    const rewardDoc = await db.collection('loyaltyRewards').doc(rewardId).get();
    
    if (!rewardDoc.exists) {
      throw new AppError(errorCodes.REWARD_NOT_FOUND, 'Reward not found');
    }
    
    const reward = rewardDoc.data() as LoyaltyReward;
    
    await db.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(db.collection('users').doc(userId));
      
      if (!userDoc.exists) {
        throw new AppError(errorCodes.USER_NOT_FOUND, 'User not found');
      }
      
      const currentPoints = userDoc.data()?.loyaltyPoints || 0;
      
      if (currentPoints < reward.pointsCost) {
        throw new AppError(
          errorCodes.INSUFFICIENT_POINTS,
          'Insufficient loyalty points'
        );
      }
      
      // Déduire les points
      transaction.update(userDoc.ref, {
        loyaltyPoints: currentPoints - reward.pointsCost
      });
      
      // Enregistrer la transaction
      const redemption: LoyaltyTransaction = {
        userId,
        points: -reward.pointsCost,
        type: 'REDEEMED',
        reason: `Redeemed for ${reward.name}`,
        rewardId,
        date: new Date()
      };
      
      transaction.create(
        db.collection('loyaltyTransactions').doc(),
        redemption
      );
    });
    
    return reward;
  } catch (error) {
    console.error('Error redeeming loyalty points:', error);
    throw new AppError(errorCodes.POINTS_REDEMPTION_FAILED, 'Failed to redeem points');
  }
}

// Services d'abonnement
export async function createOrUpdateSubscription(
  userId: string,
  subscriptionType: SubscriptionType
): Promise<Subscription> {
  try {
    const subscription: Subscription = {
      userId,
      type: subscriptionType,
      startDate: new Date(),
      status: 'ACTIVE',
      lastUpdated: new Date()
    };
    
    await db.collection('subscriptions')
      .doc(userId)
      .set(subscription, { merge: true });
    
    return subscription;
  } catch (error) {
    console.error('Error updating subscription:', error);
    throw new AppError(errorCodes.SUBSCRIPTION_UPDATE_FAILED, 'Failed to update subscription');
  }
}

export async function getSubscription(userId: string): Promise<Subscription | null> {
  try {
    const subDoc = await db.collection('subscriptions').doc(userId).get();
    
    if (!subDoc.exists) {
      return null;
    }
    
    return subDoc.data() as Subscription;
  } catch (error) {
    console.error('Error fetching subscription:', error);
    throw new AppError(errorCodes.SUBSCRIPTION_FETCH_FAILED, 'Failed to fetch subscription');
  }
}

export async function cancelSubscription(userId: string): Promise<boolean> {
  try {
    await db.collection('subscriptions').doc(userId).update({
      status: 'CANCELLED',
      cancellationDate: new Date(),
      lastUpdated: new Date()
    });
    
    return true;
  } catch (error) {
    console.error('Error cancelling subscription:', error);
    throw new AppError(errorCodes.SUBSCRIPTION_CANCELLATION_FAILED, 'Failed to cancel subscription');
  }
}

// Services de statistiques de facturation
export async function getBillingStatistics(startDate?: Date, endDate?: Date) {
  try {
    let query = db.collection('bills');
    
    if (startDate) {
      query = query.where('creationDate', '>=', startDate);
    }
    if (endDate) {
      query = query.where('creationDate', '<=', endDate);
    }
    
    const billsSnapshot = await query.get();
    const bills = billsSnapshot.docs.map(doc => doc.data() as Bill);
    
    // Calculer les statistiques
    const stats = {
      totalRevenue: bills.reduce((sum, bill) => sum + (bill.totalAmount || 0), 0),
      totalBills: bills.length,
      averageBillAmount: 0,
      paidBills: bills.filter(b => b.status === BillStatus.PAID).length,
      pendingBills: bills.filter(b => b.status === BillStatus.PENDING).length,
      subscriptionRevenue: bills
        .filter(b => b.type === 'SUBSCRIPTION')
        .reduce((sum, bill) => sum + (bill.totalAmount || 0), 0)
    };
    
    stats.averageBillAmount = stats.totalRevenue / (stats.totalBills || 1);
    
    return stats;
  } catch (error) {
    console.error('Error fetching billing statistics:', error);
    throw new AppError(errorCodes.BILLING_STATS_FETCH_FAILED, 'Failed to fetch billing statistics');
  }
}
