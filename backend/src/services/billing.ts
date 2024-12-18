import { getBill, createBill, updateBill, deleteBill } from './billing/billManagement';
import { payBill, refundBill } from './billing/paymentProcessing';
import { applyLoyaltyPointsToBill, applySubscriptionDiscountToBill, getLoyaltyTransaction, createLoyaltyTransaction, updateLoyaltyTransaction, deleteLoyaltyTransaction, getOffer, createOffer, updateOffer, deleteOffer } from './billing/loyaltyAndSubscription';
import { getBillingStats } from './billing/billingAnalytics';
import { Bill, BillStatus, PaymentMethod, RefundStatus } from '../models/bill';
import { AppError, errorCodes } from '../utils/errors';
import { LoyaltyTransaction } from '../models/loyalty/loyaltyTransaction';
import { Offer } from '../models/offer';

export class BillingService {
  async createBill(billData: Bill): Promise<Bill> {
    return createBill(billData);
  }

  async getBillById(billId: string): Promise<Bill | null> {
    return getBill(billId);
  }

  async updateBill(billId: string, updates: Partial<Bill>): Promise<Bill> {
    return updateBill(billId, updates);
  }

  async deleteBill(billId: string): Promise<void> {
    return deleteBill(billId);
  }

  async payBill(billId: string, paymentMethod: PaymentMethod, amountPaid: number, userId: string): Promise<Bill> {
    return payBill(billId, paymentMethod, amountPaid, userId);
  }

  async refundBill(billId: string, refundReason: string, userId: string, refundAmount?: number): Promise<Bill> {
    return refundBill(billId, refundReason, userId, refundAmount);
  }

  async applyLoyaltyPointsToBill(billId: string, userId: string, rewardId: string): Promise<Bill> {
    return applyLoyaltyPointsToBill(billId, userId, rewardId);
  }

  async applySubscriptionDiscountToBill(billId: string, userId: string, planId: string): Promise<Bill> {
    return applySubscriptionDiscountToBill(billId, userId, planId);
  }

  async getBillsForUser(userId: string, options: {
    page?: number;
    limit?: number;
    status?: BillStatus;
  } = {}): Promise<{ bills: Bill[]; total: number }> {
    // Implementation for getting bills for a user
    return { bills: [], total: 0 };
  }

  async getBillsForSubscriptionPlan(planId: string, options: {
    page?: number;
    limit?: number;
    status?: BillStatus;
  } = {}): Promise<{ bills: Bill[]; total: number }> {
    // Implementation for getting bills for a subscription plan
    return { bills: [], total: 0 };
  }

  async getBillingStats(startDate: Date, endDate: Date): Promise<{
    totalRevenue: number;
    totalBills: number;
    averageBillAmount: number;
    billsByStatus: { [status: string]: number };
  }> {
    return getBillingStats(startDate, endDate);
  }

  async getLoyaltyTransaction(id: string): Promise<LoyaltyTransaction | null> {
    return getLoyaltyTransaction(id);
  }

  async createLoyaltyTransaction(transactionData: LoyaltyTransaction): Promise<LoyaltyTransaction> {
    return createLoyaltyTransaction(transactionData);
  }

  async updateLoyaltyTransaction(id: string, transactionData: Partial<LoyaltyTransaction>): Promise<LoyaltyTransaction> {
    return updateLoyaltyTransaction(id, transactionData);
  }

  async deleteLoyaltyTransaction(id: string): Promise<void> {
    return deleteLoyaltyTransaction(id);
  }

  async getOffer(id: string): Promise<Offer | null> {
    return getOffer(id);
  }

  async createOffer(offerData: Offer): Promise<Offer> {
    return createOffer(offerData);
  }

  async updateOffer(id: string, offerData: Partial<Offer>): Promise<Offer> {
    return updateOffer(id, offerData);
  }

  async deleteOffer(id: string): Promise<void> {
    return deleteOffer(id);
  }
}

export const billingService = new BillingService();
