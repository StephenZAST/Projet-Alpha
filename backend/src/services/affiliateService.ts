import { Affiliate, AffiliateStatus, PayoutStatus, CommissionWithdrawal } from '../models/affiliate';
import { AppError, errorCodes } from '../utils/errors';
import { createAffiliate, approveAffiliate, getAffiliateProfile, updateProfile, getPendingAffiliates, getAllAffiliates, getAffiliateById, deleteAffiliate, updateAffiliate } from './affiliateService/affiliateManagement';
import { requestCommissionWithdrawal, getCommissionWithdrawals, updateCommissionWithdrawalStatus, getWithdrawalHistory, getPendingWithdrawals, processWithdrawal } from './affiliateService/commissionWithdrawal';
import { getAnalytics, getAffiliateStats } from './affiliateService/analytics';

export class AffiliateService {
  async createAffiliate(
    firstName: string,
    lastName: string,
    email: string,
    phoneNumber: string,
    address: string,
    orderPreferences: Affiliate['orderPreferences'],
    paymentInfo: Affiliate['paymentInfo']
  ): Promise<Affiliate> {
    return createAffiliate(firstName, lastName, email, phoneNumber, address, orderPreferences, paymentInfo);
  }

  async approveAffiliate(affiliateId: string): Promise<void> {
    return approveAffiliate(affiliateId);
  }

  async requestCommissionWithdrawal(
    affiliateId: string,
    amount: number,
    paymentMethod: string,
    paymentDetails: CommissionWithdrawal['paymentDetails']
  ): Promise<CommissionWithdrawal> {
    return requestCommissionWithdrawal(affiliateId, amount, paymentMethod, paymentDetails);
  }

  async getCommissionWithdrawals(): Promise<CommissionWithdrawal[]> {
    return getCommissionWithdrawals();
  }

  async updateCommissionWithdrawalStatus(withdrawalId: string, status: PayoutStatus): Promise<CommissionWithdrawal> {
    return updateCommissionWithdrawalStatus(withdrawalId, status);
  }

  async getAffiliateProfile(affiliateId: string): Promise<Affiliate> {
    return getAffiliateProfile(affiliateId);
  }

  async updateProfile(affiliateId: string, updates: Partial<Omit<Affiliate, 'id' | 'status' | 'referralCode'>>): Promise<void> {
    return updateProfile(affiliateId, updates);
  }

  async getPendingAffiliates(): Promise<Affiliate[]> {
    return getPendingAffiliates();
  }

  async getAllAffiliates(): Promise<Affiliate[]> {
    return getAllAffiliates();
  }

  async getAffiliateById(affiliateId: string): Promise<Affiliate> {
    return getAffiliateById(affiliateId);
  }

  async deleteAffiliate(affiliateId: string): Promise<void> {
    return deleteAffiliate(affiliateId);
  }

  async updateAffiliate(affiliateId: string, affiliateData: Partial<Affiliate>): Promise<Affiliate> {
    return updateAffiliate(affiliateId, affiliateData);
  }

  async getAnalytics(): Promise<{
    totalAffiliates: number;
    pendingAffiliates: number;
    activeAffiliates: number;
    totalCommissions: number;
    totalWithdrawals: number;
  }> {
    return getAnalytics();
  }

  async getAffiliateStats(affiliateId: string): Promise<{
    totalEarnings: number;
    availableBalance: number;
    pendingCommissions: number;
    totalReferrals: number;
    conversionRate: number;
    monthlyStats: {
      month: string;
      earnings: number;
      referrals: number;
      orders: number;
    }[];
    performanceMetrics: {
      avgOrderValue: number;
      totalOrders: number;
      activeCustomers: number;
    };
  }> {
    return getAffiliateStats(affiliateId);
  }

  async getWithdrawalHistory(
    affiliateId: string,
    options: {
      limit?: number;
      offset?: number;
      startDate?: Date;
      endDate?: Date;
    } = {}
  ): Promise<{
    withdrawals: CommissionWithdrawal[];
    total: number;
    totalAmount: number;
  }> {
    return getWithdrawalHistory(affiliateId, options);
  }

  async getPendingWithdrawals(
    options: {
      limit?: number;
      offset?: number;
    } = {}
  ): Promise<{
    withdrawals: (CommissionWithdrawal & { affiliate: Pick<Affiliate, 'firstName' | 'lastName' | 'email' | 'phoneNumber'> })[];
    total: number;
    totalAmount: number;
  }> {
    return getPendingWithdrawals(options);
  }

  async processWithdrawal(
    withdrawalId: string,
    adminId: string,
    status: PayoutStatus,
    notes?: string
  ): Promise<void> {
    return processWithdrawal(withdrawalId, adminId, status, notes);
  }
}

export const affiliateService = new AffiliateService();
