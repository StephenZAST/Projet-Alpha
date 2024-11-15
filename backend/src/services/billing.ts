import { db } from './firebase';
import { Bill, BillStatus, PaymentStatus, RefundStatus } from '../models/billing';
import { LoyaltyTransaction, LoyaltyTransactionType, LoyaltyReward } from '../models/loyalty';
import { Subscription, SubscriptionType } from '../models/subscription';
import { AppError, errorCodes } from '../utils/errors';
import { FieldValue, Timestamp } from 'firebase-admin/firestore';

// Services de facturation
export async function createBill(bill: Omit<Bill, 'id' | 'createdAt' | 'updatedAt' | 'status' | 'paymentStatus'>): Promise<Bill> {
  try {
    const newBill: Bill = {
      ...bill,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      status: BillStatus.DRAFT,
      paymentStatus: PaymentStatus.PENDING,
      total: calculateTotal(bill)
    };

    const billRef = await db.collection('bills').add(newBill);
    return { ...newBill, id: billRef.id };
  } catch (error) {
    console.error('Error creating bill:', error);
    throw new AppError(500, 'Failed to create bill', errorCodes.BILL_CREATION_FAILED);
  }
}

function calculateTotal(bill: Pick<Bill, 'subtotal' | 'tax' | 'discount' | 'loyaltyPointsUsed'>): number {
  let total = bill.subtotal + bill.tax;
  if (bill.discount) {
    total -= bill.discount;
  }
  if (bill.loyaltyPointsUsed) {
    // Conversion des points en valeur monétaire (1 point = 0.1 unité)
    total -= bill.loyaltyPointsUsed * 0.1;
  }
  return Math.max(0, total);
}

export async function updateBillStatus(
  billId: string,
  status: BillStatus,
  paymentStatus?: PaymentStatus,
  refundStatus?: RefundStatus
): Promise<Bill> {
  try {
    const billRef = db.collection('bills').doc(billId);
    const billDoc = await billRef.get();

    if (!billDoc.exists) {
      throw new AppError(404, 'Bill not found', errorCodes.BILL_NOT_FOUND);
    }

    const updateData: Partial<Bill> = {
      status,
      updatedAt: Timestamp.now()
    };

    if (paymentStatus) {
      updateData.paymentStatus = paymentStatus;
      if (paymentStatus === PaymentStatus.COMPLETED) {
        updateData.paymentDate = Timestamp.now();
      }
    }

    if (refundStatus) {
      updateData.refundStatus = refundStatus;
      if (refundStatus === RefundStatus.COMPLETED) {
        updateData.refundDate = Timestamp.now();
      }
    }

    await billRef.update(updateData);
    
    const updatedBill = await billRef.get();
    return { id: billId, ...updatedBill.data() } as Bill;
  } catch (error) {
    console.error('Error updating bill status:', error);
    throw new AppError(500, 'Failed to update bill status', errorCodes.BILL_UPDATE_FAILED);
  }
}

export async function processBillPayment(
  billId: string,
  paymentMethod: string,
  amount: number
): Promise<Bill> {
  try {
    const billRef = db.collection('bills').doc(billId);
    const billDoc = await billRef.get();

    if (!billDoc.exists) {
      throw new AppError(404, 'Bill not found', errorCodes.BILL_NOT_FOUND);
    }

    const bill = billDoc.data() as Bill;
    
    if (bill.status === BillStatus.PAID) {
      throw new AppError(400, 'Bill is already paid', errorCodes.BILL_ALREADY_PAID);
    }

    if (amount < bill.total) {
      throw new AppError(400, 'Payment amount is insufficient', errorCodes.INSUFFICIENT_PAYMENT);
    }

    const updateData: Partial<Bill> = {
      status: BillStatus.PAID,
      paymentStatus: PaymentStatus.COMPLETED,
      paymentMethod,
      paymentDate: Timestamp.now(),
      updatedAt: Timestamp.now()
    };

    await billRef.update(updateData);

    // Add loyalty points if applicable
    if (bill.loyaltyPointsEarned > 0) {
      await addLoyaltyPoints(
        bill.userId,
        bill.loyaltyPointsEarned,
        `Points earned from bill ${billId}`
      );
    }

    const updatedBill = await billRef.get();
    return { id: billId, ...updatedBill.data() } as Bill;
  } catch (error) {
    console.error('Error processing bill payment:', error);
    throw new AppError(500, 'Failed to process payment', errorCodes.PAYMENT_PROCESSING_FAILED);
  }
}

export async function processBillRefund(
  billId: string,
  amount: number,
  reason: string
): Promise<Bill> {
  try {
    const billRef = db.collection('bills').doc(billId);
    const billDoc = await billRef.get();

    if (!billDoc.exists) {
      throw new AppError(404, 'Bill not found', errorCodes.BILL_NOT_FOUND);
    }

    const bill = billDoc.data() as Bill;
    
    if (bill.status !== BillStatus.PAID) {
      throw new AppError(400, 'Bill must be paid to process refund', errorCodes.INVALID_REFUND_REQUEST);
    }

    if (amount > bill.total) {
      throw new AppError(400, 'Refund amount cannot exceed bill total', errorCodes.INVALID_REFUND_AMOUNT);
    }

    const status = amount === bill.total ? BillStatus.REFUNDED : BillStatus.PARTIALLY_REFUNDED;

    const updateData: Partial<Bill> = {
      status,
      refundStatus: RefundStatus.COMPLETED,
      refundAmount: amount,
      refundDate: Timestamp.now(),
      notes: reason,
      updatedAt: Timestamp.now()
    };

    await billRef.update(updateData);

    // Reverse loyalty points if applicable
    if (bill.loyaltyPointsEarned > 0) {
      const pointsToReverse = Math.floor((amount / bill.total) * bill.loyaltyPointsEarned);
      if (pointsToReverse > 0) {
        await addLoyaltyPoints(
          bill.userId,
          -pointsToReverse,
          `Points reversed from refund of bill ${billId}`
        );
      }
    }

    const updatedBill = await billRef.get();
    return { id: billId, ...updatedBill.data() } as Bill;
  } catch (error) {
    console.error('Error processing bill refund:', error);
    throw new AppError(500, 'Failed to process refund', errorCodes.REFUND_PROCESSING_FAILED);
  }
}

// Services de points de fidélité
export async function addLoyaltyPoints(
  userId: string,
  points: number,
  reason: string
): Promise<number> {
  try {
    const transaction: LoyaltyTransaction = {
      userId,
      type: points > 0 ? LoyaltyTransactionType.EARNED : LoyaltyTransactionType.ADJUSTED,
      points,
      description: reason,
      createdAt: Timestamp.now(),
      expiryDate: Timestamp.fromDate(new Date(Date.now() + 365 * 24 * 60 * 60 * 1000)) // 1 year expiry
    };

    await db.collection('loyaltyTransactions').add(transaction);
    
    const userRef = db.collection('users').doc(userId);
    await userRef.update({
      loyaltyPoints: FieldValue.increment(points)
    });

    return points;
  } catch (error) {
    console.error('Error adding loyalty points:', error);
    throw new AppError(500, 'Failed to add loyalty points', errorCodes.LOYALTY_POINTS_UPDATE_FAILED);
  }
}

export async function redeemLoyaltyPoints(
  userId: string,
  rewardId: string
): Promise<LoyaltyReward> {
  try {
    const userRef = db.collection('users').doc(userId);
    const rewardRef = db.collection('loyaltyRewards').doc(rewardId);

    const [userDoc, rewardDoc] = await Promise.all([
      userRef.get(),
      rewardRef.get()
    ]);

    if (!userDoc.exists) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    if (!rewardDoc.exists) {
      throw new AppError(404, 'Reward not found', errorCodes.REWARD_NOT_FOUND);
    }

    const user = userDoc.data();
    const reward = rewardDoc.data() as LoyaltyReward;

    if (!user || user.loyaltyPoints < reward.pointsCost) {
      throw new AppError(400, 'Insufficient loyalty points', errorCodes.INSUFFICIENT_POINTS);
    }

    const transaction: LoyaltyTransaction = {
      userId,
      type: LoyaltyTransactionType.REDEEMED,
      points: -reward.pointsCost,
      description: `Redeemed reward: ${reward.name}`,
      createdAt: Timestamp.now()
    };

    await Promise.all([
      db.collection('loyaltyTransactions').add(transaction),
      userRef.update({
        loyaltyPoints: FieldValue.increment(-reward.pointsCost)
      })
    ]);

    return reward;
  } catch (error) {
    console.error('Error redeeming loyalty points:', error);
    throw new AppError(500, 'Failed to redeem loyalty points', errorCodes.LOYALTY_POINTS_UPDATE_FAILED);
  }
}

// Services d'abonnement
export async function createOrUpdateSubscription(
  userId: string,
  subscriptionType: SubscriptionType
): Promise<Subscription> {
  try {
    const subscription: Subscription = {
      type: subscriptionType,
      startDate: Timestamp.now(),
      status: 'active',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now()
    };

    await db.collection('subscriptions').doc(userId).set(subscription);
    return { ...subscription, id: userId };
  } catch (error) {
    console.error('Error creating/updating subscription:', error);
    throw new AppError(500, 'Failed to create/update subscription', errorCodes.SUBSCRIPTION_UPDATE_FAILED);
  }
}

// Services de statistiques de facturation
export async function getBillingStatistics(startDate?: Date, endDate?: Date) {
  try {
    let billsQuery = db.collection('bills');

    if (startDate) {
      billsQuery = billsQuery.where('createdAt', '>=', Timestamp.fromDate(startDate));
    }
    if (endDate) {
      billsQuery = billsQuery.where('createdAt', '<=', Timestamp.fromDate(endDate));
    }

    const billsSnapshot = await billsQuery.get();
    const bills = billsSnapshot.docs.map(doc => ({ ...doc.data(), id: doc.id })) as Bill[];

    const stats = {
      totalBills: bills.length,
      totalRevenue: bills.reduce((sum, bill) => sum + (bill.status === BillStatus.PAID ? bill.total : 0), 0),
      averageOrderValue: 0,
      billsByStatus: {} as Record<BillStatus, number>,
      refundedAmount: bills.reduce((sum, bill) => sum + (bill.refundAmount || 0), 0),
      loyaltyPointsIssued: bills.reduce((sum, bill) => sum + (bill.loyaltyPointsEarned || 0), 0),
      loyaltyPointsRedeemed: bills.reduce((sum, bill) => sum + (bill.loyaltyPointsUsed || 0), 0)
    };

    stats.averageOrderValue = stats.totalRevenue / bills.filter(bill => bill.status === BillStatus.PAID).length;

    bills.forEach(bill => {
      if (!stats.billsByStatus[bill.status]) {
        stats.billsByStatus[bill.status] = 0;
      }
      stats.billsByStatus[bill.status]++;
    });

    return stats;
  } catch (error) {
    console.error('Error getting billing statistics:', error);
    throw new AppError(500, 'Failed to get billing statistics', errorCodes.BILLING_STATS_FETCH_FAILED);
  }
}
