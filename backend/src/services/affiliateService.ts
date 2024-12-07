import { db, Timestamp } from '../config/firebase';
import { Affiliate, AffiliateStatus, CommissionWithdrawal, PayoutStatus } from '../models/affiliate';
import { Commission } from '../models/commission';
import { CodeGenerator } from '../utils/codeGenerator';
import { AppError, errorCodes } from '../utils/errors';
import { notificationService, NotificationType, NotificationStatus } from './notificationService';
import { PaymentMethod } from '../models/order';

export class AffiliateService {
    private affiliatesRef = db.collection('affiliates');
    private commissionsRef = db.collection('commissions');
    private withdrawalsRef = db.collection('commission-withdrawals');

    async createAffiliate(
        fullName: string,
        email: string,
        phone: string,
        paymentInfo: Affiliate['paymentInfo']
    ): Promise<Affiliate> {
        try {
            // Check if email is already used
            const existingAffiliate = await this.affiliatesRef
                .where('email', '==', email)
                .get();

            if (!existingAffiliate.empty) {
                throw new AppError(400, 'Email already registered as affiliate', errorCodes.EMAIL_ALREADY_REGISTERED);
            }

            const affiliate: Omit<Affiliate, 'id'> = {
                firstName: fullName.split(' ')[0],
                lastName: fullName.split(' ').slice(1).join(' '),
                email,
                phoneNumber: phone,
                status: AffiliateStatus.PENDING,
                paymentInfo,
                commissionRate: 10, // 10% default
                totalEarnings: 0,
                availableBalance: 0,
                referralCode: await CodeGenerator.generateAffiliateCode(),
                referralClicks: 0,
                address: '', // You might want to collect this during signup
                orderPreferences: {
                    allowedOrderTypes: [], // You might want to collect this during signup
                    allowedPaymentMethods: [] // You might want to collect this during signup
                },
                createdAt: new Date(),
                updatedAt: new Date()
            };

            const docRef = await this.affiliatesRef.add(affiliate);
            return { ...affiliate, id: docRef.id } as Affiliate;
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError(500, 'Failed to create affiliate', errorCodes.AFFILIATE_CREATION_FAILED);
        }
    }

    async approveAffiliate(affiliateId: string): Promise<void> {
        try {
            const affiliateRef = this.affiliatesRef.doc(affiliateId);
            const affiliate = await affiliateRef.get();

            if (!affiliate.exists) {
                throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
            }

            if (affiliate.data()?.status === AffiliateStatus.ACTIVE) {
                throw new AppError(400, 'Affiliate is already active', errorCodes.AFFILIATE_ALREADY_ACTIVE);
            }

            await affiliateRef.update({
                status: AffiliateStatus.ACTIVE,
                updatedAt: Timestamp.now()
            });

            // Notify affiliate
            await notificationService.createNotification({
                userId: affiliateId,
                title: 'Affiliate Application Approved',
                message: 'Your affiliate application has been approved. You can now start referring customers.',
                type: NotificationType.AFFILIATE_APPROVED,
                status: NotificationStatus.UNREAD
            });
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError(500, 'Failed to approve affiliate', errorCodes.AFFILIATE_UPDATE_FAILED);
        }
    }

    async requestWithdrawal(
        affiliateId: string,
        amount: number,
        paymentMethod: PaymentMethod
    ): Promise<CommissionWithdrawal> {
        try {
            const affiliateRef = this.affiliatesRef.doc(affiliateId);
            const affiliate = await affiliateRef.get();

            if (!affiliate.exists) {
                throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
            }

            const affiliateData = affiliate.data() as Affiliate;

            if (affiliateData.availableBalance < amount) {
                throw new AppError(400, 'Insufficient balance', errorCodes.INSUFFICIENT_BALANCE);
            }

            if (amount < 1000) {
                throw new AppError(400, 'Minimum withdrawal amount is 1000 FCFA', errorCodes.MINIMUM_WITHDRAWAL_AMOUNT);
            }

            const withdrawal: Omit<CommissionWithdrawal, 'id'> = {
                affiliateId,
                amount,
                paymentMethod,
                paymentDetails: {
                    mobileMoneyNumber: paymentMethod === PaymentMethod.MOBILE_MONEY
                        ? affiliateData.paymentInfo.mobileMoneyNumber
                        : undefined,
                    bankInfo: paymentMethod === PaymentMethod.BANK_TRANSFER
                        ? affiliateData.paymentInfo.bankInfo
                        : undefined
                },
                status: PayoutStatus.PENDING,
                requestedAt: new Date(),
                processedAt: null,
                processedBy: null
            };

            const docRef = await this.withdrawalsRef.add(withdrawal);
            return { ...withdrawal, id: docRef.id } as CommissionWithdrawal;
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError(500, 'Failed to create withdrawal request', errorCodes.WITHDRAWAL_REQUEST_NOT_FOUND);
        }
    }

    async getAffiliateProfile(affiliateId: string): Promise<Affiliate> {
        try {
            const affiliateDoc = await this.affiliatesRef.doc(affiliateId).get();

            if (!affiliateDoc.exists) {
                throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
            }

            return { id: affiliateDoc.id, ...affiliateDoc.data() } as Affiliate;
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError(500, 'Failed to fetch affiliate profile', errorCodes.AFFILIATE_FETCH_FAILED);
        }
    }

    async updateProfile(affiliateId: string, updates: Partial<Omit<Affiliate, 'id' | 'status' | 'referralCode'>>): Promise<void> {
        try {
            const affiliateRef = this.affiliatesRef.doc(affiliateId);
            const affiliate = await affiliateRef.get();

            if (!affiliate.exists) {
                throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
            }

            await affiliateRef.update({
                ...updates,
                updatedAt: Timestamp.now()
            });
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError(500, 'Failed to update affiliate profile', errorCodes.AFFILIATE_UPDATE_FAILED);
        }
    }

    async getPendingAffiliates(): Promise<Affiliate[]> {
        try {
            const snapshot = await this.affiliatesRef
                .where('status', '==', AffiliateStatus.PENDING)
                .orderBy('createdAt', 'desc')
                .get();

            return snapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            })) as Affiliate[];
        } catch (error) {
            throw new AppError(500, 'Failed to fetch pending affiliates', errorCodes.AFFILIATE_FETCH_FAILED);
        }
    }

    async getAllAffiliates(): Promise<Affiliate[]> {
        try {
            const snapshot = await this.affiliatesRef
                .orderBy('createdAt', 'desc')
                .get();

            return snapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            })) as Affiliate[];
        } catch (error) {
            throw new AppError(500, 'Failed to fetch all affiliates', errorCodes.AFFILIATE_FETCH_FAILED);
        }
    }

    async getAnalytics(): Promise<{
        totalAffiliates: number;
        pendingAffiliates: number;
        activeAffiliates: number;
        totalCommissions: number;
        totalWithdrawals: number;
    }> {
        try {
            const [affiliatesSnapshot, commissionsSnapshot, withdrawalsSnapshot] = await Promise.all([
                this.affiliatesRef.get(),
                this.commissionsRef.get(),
                this.withdrawalsRef.get()
            ]);

            const affiliates = affiliatesSnapshot.docs.map(doc => doc.data() as Affiliate);

            return {
                totalAffiliates: affiliates.length,
                pendingAffiliates: affiliates.filter(a => a.status === AffiliateStatus.PENDING).length,
                activeAffiliates: affiliates.filter(a => a.status === AffiliateStatus.ACTIVE).length,
                totalCommissions: commissionsSnapshot.size,
                totalWithdrawals: withdrawalsSnapshot.size
            };
        } catch (error) {
            throw new AppError(500, 'Failed to fetch analytics', errorCodes.ANALYTICS_NOT_FOUND);
        }
    }

    async processWithdrawal(
        withdrawalId: string,
        adminId: string,
        status: PayoutStatus,
        notes?: string
    ): Promise<void> {
        try {
            const withdrawalRef = this.withdrawalsRef.doc(withdrawalId);
            const withdrawal = await withdrawalRef.get();

            if (!withdrawal.exists) {
                throw new AppError(404, 'Withdrawal request not found', errorCodes.WITHDRAWAL_REQUEST_NOT_FOUND);
            }

            const withdrawalData = withdrawal.data() as CommissionWithdrawal;
            const affiliateRef = this.affiliatesRef.doc(withdrawalData.affiliateId);

            if (status === PayoutStatus.COMPLETED) {
                await db.runTransaction(async (transaction) => {
                    const affiliate = await transaction.get(affiliateRef);
                    const currentBalance = affiliate.data()?.availableBalance || 0;

                    if (currentBalance < withdrawalData.amount) {
                        throw new AppError(400, 'Insufficient balance', errorCodes.INSUFFICIENT_BALANCE);
                    }

                    // Update affiliate balance
                    transaction.update(affiliateRef, {
                        availableBalance: currentBalance - withdrawalData.amount,
                        updatedAt: Timestamp.now()
                    });

                    // Mark withdrawal as completed
                    transaction.update(withdrawalRef, {
                        status,
                        processedBy: adminId,
                        processedAt: Timestamp.now(),
                        notes
                    });
                });

                // Notify affiliate
                await notificationService.createNotification({
                    userId: withdrawalData.affiliateId,
                    title: 'Withdrawal Completed',
                    message: `Your withdrawal request for ${withdrawalData.amount} FCFA has been completed.`,
                    type: NotificationType.PAYMENT_STATUS,
                    status: NotificationStatus.UNREAD
                });
            } else if (status === PayoutStatus.FAILED) {
                // Mark withdrawal as rejected
                await withdrawalRef.update({
                    status,
                    processedBy: adminId,
                    processedAt: Timestamp.now(),
                    notes
                });

                // Notify affiliate
                await notificationService.createNotification({
                    userId: withdrawalData.affiliateId,
                    title: 'Withdrawal Rejected',
                    message: `Your withdrawal request for ${withdrawalData.amount} FCFA has been rejected. Reason: ${notes}`,
                    type: NotificationType.PAYMENT_STATUS,
                    status: NotificationStatus.UNREAD
                });
            }
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError(500, 'Failed to process withdrawal', errorCodes.WITHDRAWAL_PROCESSING_FAILED);
        }
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
        try {
            // Get affiliate profile
            const affiliateDoc = await this.affiliatesRef.doc(affiliateId).get();
            if (!affiliateDoc.exists) {
                throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
            }
            const affiliate = affiliateDoc.data() as Affiliate;

            // Get all commissions for this affiliate
            const commissionsSnapshot = await this.commissionsRef
                .where('affiliateId', '==', affiliateId)
                .get();

            const commissions = commissionsSnapshot.docs.map(doc => doc.data() as Commission);

            // Calculate pending commissions
            const pendingCommissions = commissions.length > 0
                ? commissions
                    .filter(c => c.status === 'PENDING')
                    .reduce((sum, c) => sum + c.commissionAmount, 0)
                : 0;

            // Get referral orders from orders collection
            const ordersSnapshot = await db.collection('orders')
                .where('referralCode', '==', affiliate.referralCode)
                .get();

            const orders = ordersSnapshot.docs.map(doc => doc.data());

            // Calculate monthly stats for the last 6 months
            const monthlyStats = this.calculateMonthlyStats(commissions, orders);

            // Calculate performance metrics
            const performanceMetrics = this.calculatePerformanceMetrics(orders);

            // Calculate conversion rate (orders / total referral clicks)
            const conversionRate = affiliate.referralClicks ? (orders.length / affiliate.referralClicks) * 100 : 0;

            return {
                totalEarnings: affiliate.totalEarnings,
                availableBalance: affiliate.availableBalance,
                pendingCommissions,
                totalReferrals: orders.length,
                conversionRate,
                monthlyStats,
                performanceMetrics
            };
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError(500, 'Failed to fetch affiliate stats', errorCodes.AFFILIATE_STATS_FETCH_FAILED);
        }
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
        try {
            let query = this.withdrawalsRef
                .where('affiliateId', '==', affiliateId)
                .orderBy('requestedAt', 'desc');

            // Apply date filters if provided
            if (options.startDate) {
                query = query.where('requestedAt', '>=', Timestamp.fromDate(options.startDate));
            }
            if (options.endDate) {
                query = query.where('requestedAt', '<=', Timestamp.fromDate(options.endDate));
            }

            // Get total count
            const totalSnapshot = await query.get();
            const total = totalSnapshot.size;

            // Apply pagination
            if (options.limit) {
                query = query.limit(options.limit);
            }
            if (options.offset) {
                query = query.offset(options.offset);
            }

            const snapshot = await query.get();

            const withdrawals = snapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            })) as CommissionWithdrawal[];

            const totalAmount = withdrawals.reduce((sum, w) => sum + w.amount, 0);

            return {
                withdrawals,
                total,
                totalAmount
            };
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError(500, 'Failed to fetch withdrawal history', errorCodes.WITHDRAWAL_HISTORY_FETCH_FAILED);
        }
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
        try {
            let query = this.withdrawalsRef
                .where('status', '==', 'PENDING')
                .orderBy('requestedAt', 'desc');

            // Get total count
            const totalSnapshot = await query.get();
            const total = totalSnapshot.size;

            // Apply pagination
            if (options.limit) {
                query = query.limit(options.limit);
            }
            if (options.offset) {
                query = query.offset(options.offset);
            }

            const snapshot = await query.get();

            // Get withdrawals with affiliate info
            const withdrawalsPromises = snapshot.docs.map(async doc => {
                const withdrawal = { id: doc.id, ...doc.data() } as CommissionWithdrawal;
                const affiliateDoc = await this.affiliatesRef.doc(withdrawal.affiliateId).get();
                const affiliate = affiliateDoc.data() as Affiliate;

                return {
                    ...withdrawal,
                    affiliate: {
                        firstName: affiliate.firstName,
                        lastName: affiliate.lastName,
                        email: affiliate.email,
                        phoneNumber: affiliate.phoneNumber
                    }
                };
            });

            const withdrawals = await Promise.all(withdrawalsPromises);
            const totalAmount = withdrawals.reduce((sum, w) => sum + w.amount, 0);

            return {
                withdrawals,
                total,
                totalAmount
            };
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError(500, 'Failed to fetch pending withdrawals', errorCodes.PENDING_WITHDRAWALS_FETCH_FAILED);
        }
    }

    private calculateMonthlyStats(commissions: Commission[], orders: any[]): {
        month: string;
        earnings: number;
        referrals: number;
        orders: number;
    }[] {
        const last6Months = Array.from({ length: 6 }, (_, i) => {
            const date = new Date();
            date.setMonth(date.getMonth() - i);
            return date.toISOString().substring(0, 7); // YYYY-MM format
        });

        return last6Months.map(month => {
            const monthCommissions = commissions.filter(c =>
                c.createdAt.toDate().toISOString().startsWith(month)
            );
            const monthOrders = orders.filter(o =>
                o.createdAt?.toDate().toISOString().startsWith(month)
            );

            return {
                month,
                earnings: monthCommissions.reduce((sum, c) => sum + c.commissionAmount, 0),
                referrals: monthOrders.length,
                orders: monthOrders.length
            };
        });
    }

    private calculatePerformanceMetrics(orders: any[]): {
        avgOrderValue: number;
        totalOrders: number;
        activeCustomers: number;
    } {
        const totalOrders = orders.length;
        const totalValue = orders.reduce((sum, order) => sum + (order.totalAmount || 0), 0);
        const uniqueCustomers = new Set(orders.map(order => order.customerId)).size;

        return {
            avgOrderValue: totalOrders > 0 ? totalValue / totalOrders : 0,
            totalOrders,
            activeCustomers: uniqueCustomers
        };
    }

    async getAffiliateById(affiliateId: string): Promise<Affiliate> {
        try {
            const affiliateDoc = await this.affiliatesRef.doc(affiliateId).get();

            if (!affiliateDoc.exists) {
                throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
            }

            return { id: affiliateDoc.id, ...affiliateDoc.data() } as Affiliate;
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError(500, 'Failed to get affiliate', errorCodes.AFFILIATE_NOT_FOUND);
        }
    }

    async deleteAffiliate(affiliateId: string): Promise<void> {
        try {
            const affiliateRef = this.affiliatesRef.doc(affiliateId);
            const affiliateDoc = await affiliateRef.get();

            if (!affiliateDoc.exists) {
                throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
            }

            // Delete the affiliate
            await affiliateRef.delete();

            // Delete associated commissions
            const commissionsSnapshot = await this.commissionsRef.where('affiliateId', '==', affiliateId).get();
            const commissionsDeletePromises = commissionsSnapshot.docs.map(doc => doc.ref.delete());
            await Promise.all(commissionsDeletePromises);

            // Delete associated withdrawal requests
            const withdrawalsSnapshot = await this.withdrawalsRef.where('affiliateId', '==', affiliateId).get();
            const withdrawalsDeletePromises = withdrawalsSnapshot.docs.map(doc => doc.ref.delete());
            await Promise.all(withdrawalsDeletePromises);

            // TODO: Consider deleting associated notifications

        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError(500, 'Failed to delete affiliate', errorCodes.AFFILIATE_DELETION_FAILED);
        }
    }
}

export const affiliateService = new AffiliateService();
