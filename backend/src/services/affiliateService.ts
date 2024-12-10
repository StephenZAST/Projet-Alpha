import { Timestamp } from '../config/firebase';
import { Affiliate, AffiliateStatus, PayoutStatus, CommissionWithdrawal } from '../models/affiliate';
import { PaymentMethod } from '../models/order';
import * as AffiliateManagement from './affiliateService/affiliateManagement';
import * as CommissionWithdrawalModule from './affiliateService/commissionWithdrawal';
import * as Analytics from './affiliateService/analytics';

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
        return AffiliateManagement.createAffiliate(firstName, lastName, email, phoneNumber, address, orderPreferences, paymentInfo);
    }

    async approveAffiliate(affiliateId: string): Promise<void> {
        return AffiliateManagement.approveAffiliate(affiliateId);
    }

    async requestCommissionWithdrawal(
        affiliateId: string,
        amount: number,
        paymentMethod: PaymentMethod
    ): Promise<CommissionWithdrawal> {
        return CommissionWithdrawalModule.requestCommissionWithdrawal(affiliateId, amount, paymentMethod);
    }

    async getCommissionWithdrawals(): Promise<CommissionWithdrawal[]> {
        return CommissionWithdrawalModule.getCommissionWithdrawals();
    }

    async updateCommissionWithdrawalStatus(withdrawalId: string, status: PayoutStatus): Promise<CommissionWithdrawal> {
        return CommissionWithdrawalModule.updateCommissionWithdrawalStatus(withdrawalId, status);
    }

    async getAffiliateProfile(affiliateId: string): Promise<Affiliate> {
        return AffiliateManagement.getAffiliateProfile(affiliateId);
    }

    async updateProfile(affiliateId: string, updates: Partial<Omit<Affiliate, 'id' | 'status' | 'referralCode'>>): Promise<void> {
        return AffiliateManagement.updateProfile(affiliateId, updates);
    }

    async getPendingAffiliates(): Promise<Affiliate[]> {
        return AffiliateManagement.getPendingAffiliates();
    }

    async getAllAffiliates(): Promise<Affiliate[]> {
        return AffiliateManagement.getAllAffiliates();
    }

    async getAnalytics(): Promise<{
        totalAffiliates: number;
        pendingAffiliates: number;
        activeAffiliates: number;
        totalCommissions: number;
        totalWithdrawals: number;
    }> {
        return Analytics.getAnalytics();
    }

    async processWithdrawal(
        withdrawalId: string,
        adminId: string,
        status: PayoutStatus,
        notes?: string
    ): Promise<void> {
        return CommissionWithdrawalModule.processWithdrawal(withdrawalId, adminId, status, notes);
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
        return Analytics.getAffiliateStats(affiliateId);
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
        return CommissionWithdrawalModule.getWithdrawalHistory(affiliateId, options);
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
        return CommissionWithdrawalModule.getPendingWithdrawals(options);
    }

    async getAffiliateById(affiliateId: string): Promise<Affiliate> {
        return AffiliateManagement.getAffiliateById(affiliateId);
    }

    async deleteAffiliate(affiliateId: string): Promise<void> {
        return AffiliateManagement.deleteAffiliate(affiliateId);
    }

    async updateAffiliate(affiliateId: string, affiliateData: Partial<Affiliate>): Promise<Affiliate> {
        return AffiliateManagement.updateAffiliate(affiliateId, affiliateData);
    }
}

export const affiliateService = new AffiliateService();
