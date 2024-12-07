import { db } from './firebase';
import { Bill, BillStatus, PaymentMethod } from '../models/bill'; // Import BillStatus and PaymentMethod
import { AppError, errorCodes } from '../utils/errors';
import { User } from '../models/user';
import { Reward } from '../models/loyalty';
import { SubscriptionPlan } from '../models/subscription';
import { Timestamp } from 'firebase-admin/firestore';

export class BillingService {
  async createBill(billData: Bill): Promise<Bill> {
    try {
      const billRef = await db.collection('bills').add({
        ...billData,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        status: 'pending' // Default status
      });
      const billSnapshot = await billRef.get();
      return { id: billSnapshot.id, ...billSnapshot.data() } as Bill;
    } catch (error) {
      console.error('Error creating bill:', error);
      throw new AppError(500, 'Failed to create bill', errorCodes.BILL_CREATION_FAILED); // Added missing error code
    }
  }

  async getBillById(billId: string): Promise<Bill | null> {
    try {
      const billDoc = await db.collection('bills').doc(billId).get();
      if (!billDoc.exists) {
        return null;
      }
      return { id: billDoc.id, ...billDoc.data() } as Bill;
    } catch (error) {
      console.error('Error getting bill:', error);
      throw new AppError(500, 'Failed to get bill', errorCodes.BILL_NOT_FOUND); // Added missing error code
    }
  }

  async updateBill(billId: string, updates: Partial<Bill>): Promise<Bill> {
    try {
      await db.collection('bills').doc(billId).update({
        ...updates,
        updatedAt: Timestamp.now()
      });
      const updatedBill = await this.getBillById(billId);
      if (!updatedBill) {
        throw new AppError(404, 'Bill not found after update', errorCodes.BILL_NOT_FOUND); // Added missing error code
      }
      return updatedBill;
    } catch (error) {
      console.error('Error updating bill:', error);
      throw new AppError(500, 'Failed to update bill', errorCodes.BILL_UPDATE_FAILED); // Added missing error code
    }
  }

  async payBill(billId: string, paymentMethod: PaymentMethod, amountPaid: number, userId: string): Promise<Bill> {
    try {
      const bill = await this.getBillById(billId);
      if (!bill) {
        throw new AppError(404, 'Bill not found', errorCodes.BILL_NOT_FOUND);
      }

      if (bill.status === BillStatus.PAID) {
        throw new AppError(400, 'Bill is already paid', errorCodes.BILL_ALREADY_PAID);
      }

      if (amountPaid < bill.totalAmount) {
        throw new AppError(400, 'Insufficient payment amount', errorCodes.INSUFFICIENT_PAYMENT);
      }

      // Check if paymentMethod is defined
      if (!paymentMethod) {
        throw new AppError(400, 'Payment method is required', errorCodes.PAYMENT_METHOD_REQUIRED);
      }

      // Process payment (implementation depends on your payment gateway)
      const paymentResult = await this.processPayment(paymentMethod, amountPaid, userId, billId);

      if (paymentResult.success) {
        const updatedBill = await this.updateBill(billId, {
          status: BillStatus.PAID,
          paymentMethod: paymentMethod,
          paymentDate: Timestamp.now(),
          paymentReference: paymentResult.transactionId
        });
        return updatedBill;
      } else {
        throw new AppError(500, 'Payment processing failed', errorCodes.PAYMENT_PROCESSING_FAILED);
      }
    } catch (error) {
      console.error('Error paying bill:', error);
      throw error;
    }
  }

  async refundBill(billId: string, refundReason: string, userId: string, refundAmount?: number): Promise<Bill> {
    try {
      const bill = await this.getBillById(billId);
      if (!bill) {
        throw new AppError(404, 'Bill not found', errorCodes.BILL_NOT_FOUND);
      }

      if (bill.status !== BillStatus.PAID) {
        throw new AppError(400, 'Cannot refund an unpaid bill', errorCodes.INVALID_REFUND_REQUEST);
      }

      // Check if paymentMethod is defined
      if (!bill.paymentMethod) {
        throw new AppError(400, 'Payment method is missing for this bill', errorCodes.PAYMENT_METHOD_MISSING);
      }

      // Use the provided refundAmount or default to the totalAmount
      const refundAmountToProcess = refundAmount !== undefined ? refundAmount : bill.totalAmount;

      // Basic validation for refundAmount
      if (refundAmountToProcess <= 0 || refundAmountToProcess > bill.totalAmount) {
        throw new AppError(400, 'Invalid refund amount', errorCodes.INVALID_REFUND_AMOUNT);
      }

      // Process refund (implementation depends on your payment gateway)
      const refundResult = await this.processRefund(bill.paymentMethod, refundAmountToProcess, userId, billId);

      if (refundResult.success) {
        const updatedBill = await this.updateBill(billId, {
          status: BillStatus.REFUNDED,
          refundAmount: refundAmountToProcess,
          refundDate: Timestamp.now(),
          refundReference: refundResult.transactionId,
          refundReason
        });
        return updatedBill;
      } else {
        throw new AppError(500, 'Refund processing failed', errorCodes.REFUND_PROCESSING_FAILED);
      }
    } catch (error) {
      console.error('Error refunding bill:', error);
      throw error;
    }
  }

  async applyLoyaltyPointsToBill(billId: string, userId: string, rewardId: string): Promise<Bill> {
    try {
      const bill = await this.getBillById(billId);
      if (!bill) {
        throw new AppError(404, 'Bill not found', errorCodes.BILL_NOT_FOUND); // Added missing error code
      }

      const user = await db.collection('users').doc(userId).get();
      if (!user.exists) {
        throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND); // Added missing error code
      }

      const reward = await db.collection('rewards').doc(rewardId).get();
      if (!reward.exists) {
        throw new AppError(404, 'Reward not found', errorCodes.REWARD_NOT_FOUND); // Added missing error code
      }

      const rewardData = reward.data() as Reward;
      const userLoyaltyPoints = user.data()?.loyaltyPoints || 0;

      if (rewardData.pointsRequired !== undefined && userLoyaltyPoints < rewardData.pointsRequired) {
        throw new AppError(400, 'Insufficient loyalty points', errorCodes.INSUFFICIENT_POINTS); // Added missing error code
      }

      const discountAmount = rewardData.discountAmount || 0;
      const updatedTotalAmount = bill.totalAmount - discountAmount;

      const updatedBill = await this.updateBill(billId, { totalAmount: updatedTotalAmount });

      // Update user's loyalty points
      if (rewardData.pointsRequired !== undefined) {
        await db.collection('users').doc(userId).update({
          loyaltyPoints: userLoyaltyPoints - (rewardData.pointsRequired || 0),
          updatedAt: Timestamp.now()
        });
      }

      return updatedBill;
    } catch (error) {
      console.error('Error applying loyalty points to bill:', error);
      throw new AppError(500, 'Failed to apply loyalty points', errorCodes.LOYALTY_POINTS_UPDATE_FAILED); // Added missing error code
    }
  }

  async applySubscriptionDiscountToBill(billId: string, userId: string, planId: string): Promise<Bill> {
    try {
      const bill = await this.getBillById(billId);
      if (!bill) {
        throw new AppError(404, 'Bill not found', errorCodes.BILL_NOT_FOUND); // Added missing error code
      }

      const user = await db.collection('users').doc(userId).get();
      if (!user.exists) {
        throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND); // Added missing error code
      }

      const plan = await db.collection('subscriptionPlans').doc(planId).get();
      if (!plan.exists) {
        throw new AppError(404, 'Subscription plan not found', errorCodes.SUBSCRIPTION_PLAN_NOT_FOUND); // Added missing error code
      }

      const planData = plan.data() as SubscriptionPlan;
      const discountPercentage = planData.discountPercentage || 0;
      const discountAmount = (bill.totalAmount * discountPercentage) / 100;
      const updatedTotalAmount = bill.totalAmount - discountAmount;

      const updatedBill = await this.updateBill(billId, { totalAmount: updatedTotalAmount });

      return updatedBill;
    } catch (error) {
      console.error('Error applying subscription discount to bill:', error);
      throw new AppError(500, 'Failed to apply subscription discount', errorCodes.LOYALTY_POINTS_UPDATE_FAILED); // Added missing error code
    }
  }

  async getBillsForUser(userId: string, options: {
    page?: number;
    limit?: number;
    status?: BillStatus; // Fixed type mismatch
  } = {}): Promise<{ bills: Bill[]; total: number }> {
    try {
      let query = db.collection('bills').where('userId', '==', userId);

      if (options.status) {
        query = query.where('status', '==', options.status);
      }

      const totalSnapshot = await query.get();
      const total = totalSnapshot.size;

      if (options.page && options.limit) {
        const offset = (options.page - 1) * options.limit;
        query = query.offset(offset).limit(options.limit);
      }

      const billsSnapshot = await query.orderBy('createdAt', 'desc').get();
      const bills = billsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Bill));

      return { bills, total };
    } catch (error) {
      console.error('Error getting bills for user:', error);
      throw new AppError(500, 'Failed to get bills for user', errorCodes.BILL_FETCH_FAILED); // Added missing error code
    }
  }

  async getBillsForSubscriptionPlan(planId: string, options: {
    page?: number;
    limit?: number;
    status?: BillStatus; // Fixed type mismatch
  } = {}): Promise<{ bills: Bill[]; total: number }> {
    try {
      let query = db.collection('bills').where('subscriptionPlanId', '==', planId);

      if (options.status) {
        query = query.where('status', '==', options.status);
      }

      const totalSnapshot = await query.get();
      const total = totalSnapshot.size;

      if (options.page && options.limit) {
        const offset = (options.page - 1) * options.limit;
        query = query.offset(offset).limit(options.limit);
      }

      const billsSnapshot = await query.orderBy('createdAt', 'desc').get();
      const bills = billsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Bill));

      return { bills, total };
    } catch (error) {
      console.error('Error getting bills for subscription plan:', error);
      throw new AppError(500, 'Failed to get bills for subscription plan', errorCodes.BILL_FETCH_FAILED); // Added missing error code
    }
  }

  async getBillingStats(startDate: Date, endDate: Date): Promise<{
    totalRevenue: number;
    totalBills: number;
    averageBillAmount: number;
    billsByStatus: { [status: string]: number };
  }> {
    try {
      const billsSnapshot = await db.collection('bills')
        .where('createdAt', '>=', startDate)
        .where('createdAt', '<=', endDate)
        .get();

      const totalRevenue = billsSnapshot.docs.reduce((sum, doc) => sum + (doc.data() as Bill).totalAmount, 0);
      const totalBills = billsSnapshot.size;
      const averageBillAmount = totalBills > 0 ? totalRevenue / totalBills : 0;

      const billsByStatus: { [status: string]: number } = {};
      billsSnapshot.docs.forEach(doc => {
        const billStatus = (doc.data() as Bill).status;
        billsByStatus[billStatus] = (billsByStatus[billStatus] || 0) + 1;
      });

      return { totalRevenue, totalBills, averageBillAmount, billsByStatus };
    } catch (error) {
      console.error('Error getting billing stats:', error);
      throw new AppError(500, 'Failed to get billing stats', errorCodes.BILLING_STATS_FETCH_FAILED); // Added missing error code
    }
  }

  // Placeholder for payment processing logic
  private async processPayment(paymentMethod: PaymentMethod, amount: number, userId: string, billId: string): Promise<{ success: boolean; transactionId?: string }> {
    // Implement your payment processing logic here
    // This should interact with your payment gateway
    console.log(`Processing payment for user ${userId}, bill ${billId}, amount ${amount}, using ${paymentMethod}`);
    return { success: true, transactionId: 'mock-transaction-id' };
  }

  // Placeholder for refund processing logic
  private async processRefund(paymentMethod: PaymentMethod, amount: number, userId: string, billId: string): Promise<{ success: boolean; transactionId?: string }> {
    // Implement your refund processing logic here
    // This should interact with your payment gateway
    console.log(`Processing refund for user ${userId}, bill ${billId}, amount ${amount}, using ${paymentMethod}`);
    return { success: true, transactionId: 'mock-refund-transaction-id' };
  }
}
