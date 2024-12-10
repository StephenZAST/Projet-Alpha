import { BillManagementService } from './billing/billManagement';
import { PaymentProcessingService } from './billing/paymentProcessing';
import { LoyaltyAndSubscriptionService } from './billing/loyaltyAndSubscription';
import { BillingAnalyticsService } from './billing/billingAnalytics';
import { Bill, PaymentMethod, BillStatus } from '../models/bill';

export class BillingService {
  private billManagementService: BillManagementService;
  private paymentProcessingService: PaymentProcessingService;
  private loyaltyAndSubscriptionService: LoyaltyAndSubscriptionService;
  private billingAnalyticsService: BillingAnalyticsService;

  constructor() {
    this.billManagementService = new BillManagementService();
    this.paymentProcessingService = new PaymentProcessingService();
    this.loyaltyAndSubscriptionService = new LoyaltyAndSubscriptionService();
    this.billingAnalyticsService = new BillingAnalyticsService();
  }

  async createBill(billData: Bill): Promise<Bill> {
    return this.billManagementService.createBill(billData);
  }

  async getBillById(billId: string): Promise<Bill | null> {
    return this.billManagementService.getBillById(billId);
  }

  async updateBill(billId: string, updates: Partial<Bill>): Promise<Bill> {
    return this.billManagementService.updateBill(billId, updates);
  }

  async payBill(billId: string, paymentMethod: PaymentMethod, amountPaid: number, userId: string): Promise<Bill> {
    return this.paymentProcessingService.payBill(billId, paymentMethod, amountPaid, userId);
  }

  async refundBill(billId: string, refundReason: string, userId: string, refundAmount?: number): Promise<Bill> {
    return this.paymentProcessingService.refundBill(billId, refundReason, userId, refundAmount);
  }

  async applyLoyaltyPointsToBill(billId: string, userId: string, rewardId: string): Promise<Bill> {
    return this.loyaltyAndSubscriptionService.applyLoyaltyPointsToBill(billId, userId, rewardId);
  }

  async applySubscriptionDiscountToBill(billId: string, userId: string, planId: string): Promise<Bill> {
    return this.loyaltyAndSubscriptionService.applySubscriptionDiscountToBill(billId, userId, planId);
  }

  async getBillsForUser(userId: string, options: {
    page?: number;
    limit?: number;
    status?: BillStatus;
  } = {}): Promise<{ bills: Bill[]; total: number }> {
    return this.billManagementService.getBillsForUser(userId, options);
  }

  async getBillsForSubscriptionPlan(planId: string, options: {
    page?: number;
    limit?: number;
    status?: BillStatus;
  } = {}): Promise<{ bills: Bill[]; total: number }> {
    return this.billManagementService.getBillsForSubscriptionPlan(planId, options);
  }

  async getBillingStats(startDate: Date, endDate: Date): Promise<{
    totalRevenue: number;
    totalBills: number;
    averageBillAmount: number;
    billsByStatus: { [status: string]: number };
  }> {
    return this.billingAnalyticsService.getBillingStats(startDate, endDate);
  }
}
