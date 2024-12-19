import { getBill, createBill, updateBill, deleteBill } from './billing/billManagement';
import { payBill, refundBill } from './billing/paymentProcessing';
import { applyLoyaltyPointsToBill, applySubscriptionDiscountToBill } from './billing/loyaltyAndSubscription';
import { getBillingStats } from './billing/billingAnalytics';
import { Bill, BillStatus, PaymentMethod, RefundStatus } from '../models/bill';
import { AppError, errorCodes } from '../utils/errors';
import { getAllBills } from './billing/getAllBills';
import { generateInvoices } from './billing/generateInvoices';

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

  async getAllBills(): Promise<any[]> {
    return getAllBills();
  }

  async generateInvoices(userId: string, startDate: Date, endDate: Date): Promise<Bill[]> {
    return generateInvoices(userId, startDate, endDate);
  }
}

export const billingService = new BillingService();
