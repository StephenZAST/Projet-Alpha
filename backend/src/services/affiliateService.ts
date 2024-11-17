import { db, Timestamp } from '../config/firebase';
import { Affiliate, AffiliateStatus, PaymentMethod, CommissionWithdrawal } from '../models/affiliate';
import { Commission } from '../models/commission';
import { CodeGenerator } from '../utils/codeGenerator';
import AppError from '../utils/AppError'; // Correct import
import { errorCodes } from '../utils/errors';
import { notificationService, NotificationType, NotificationStatus } from './notificationService'; // Import NotificationType and NotificationStatus

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
                throw new AppError('Email already registered as affiliate', 400); // Remove error code
            }

            const affiliate: Omit<Affiliate, 'id'> = {
                fullName,
                email,
                phone,
                status: AffiliateStatus.PENDING,
                paymentInfo,
                commissionSettings: {
                    type: 'PERCENTAGE',
                    value: 10, // 10% default
                },
                totalEarnings: 0,
                availableBalance: 0,
                referralCode: await CodeGenerator.generateAffiliateCode(),
                referralClicks: 0, // Initialize referral clicks
                createdAt: Timestamp.now(),
                updatedAt: Timestamp.now()
            };

            const docRef = await this.affiliatesRef.add(affiliate);
            return { ...affiliate, id: docRef.id } as Affiliate;
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError('Failed to create affiliate', 500); // Remove error code
        }
    }

    async approveAffiliate(affiliateId: string): Promise<void> {
        try {
            const affiliateRef = this.affiliatesRef.doc(affiliateId);
            const affiliate = await affiliateRef.get();

            if (!affiliate.exists) {
                throw new AppError('Affiliate not found', 404); // Remove error code
            }

            if (affiliate.data()?.status === AffiliateStatus.ACTIVE) {
                throw new AppError('Affiliate is already active', 400); // Remove error code
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
                type: NotificationType.AFFILIATE_APPROVED, // Use NotificationType enum
                status: NotificationStatus.UNREAD // Use NotificationStatus enum
            });
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError('Failed to approve affiliate', 500); // Remove error code
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
                throw new AppError('Affiliate not found', 404); // Remove error code
            }

            const affiliateData = affiliate.data() as Affiliate;

            if (affiliateData.availableBalance < amount) {
                throw new AppError('Insufficient balance', 400); // Remove error code
            }

            if (amount < 1000) { // Minimum 1000 FCFA
                throw new AppError('Minimum withdrawal amount is 1000 FCFA', 400); // Remove error code
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
                status: 'PENDING',
                requestedAt: Timestamp.now()
            };

            const docRef = await this.withdrawalsRef.add(withdrawal);
            return { ...withdrawal, id: docRef.id } as CommissionWithdrawal;
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError('Failed to create withdrawal request', 500); // Remove error code
        }
    }

    async getAffiliateProfile(affiliateId: string): Promise<Affiliate> {
        try {
            const affiliateDoc = await this.affiliatesRef.doc(affiliateId).get();
            
            if (!affiliateDoc.exists) {
                throw new AppError('Affiliate not found', 404); // Remove error code
            }

            return { id: affiliateDoc.id, ...affiliateDoc.data() } as Affiliate;
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError('Failed to fetch affiliate profile', 500); // Remove error code
        }
    }

    async updateProfile(affiliateId: string, updates: Partial<Omit<Affiliate, 'id' | 'status' | 'referralCode'>>): Promise<void> {
        try {
            const affiliateRef = this.affiliatesRef.doc(affiliateId);
            const affiliate = await affiliateRef.get();

            if (!affiliate.exists) {
                throw new AppError('Affiliate not found', 404); // Remove error code
            }

            await affiliateRef.update({
                ...updates,
                updatedAt: Timestamp.now()
            });
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError('Failed to update affiliate profile', 500); // Remove error code
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
            throw new AppError('Failed to fetch pending affiliates', 500); // Remove error code
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
            throw new AppError('Failed to fetch all affiliates', 500); // Remove error code
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
            throw new AppError('Failed to fetch analytics', 500); // Remove error code
        }
    }

    async processWithdrawal(
        withdrawalId: string,
        adminId: string,
        status: 'COMPLETED' | 'REJECTED',
        notes?: string
    ): Promise<void> {
        try {
            const withdrawalRef = this.withdrawalsRef.doc(withdrawalId);
            const withdrawal = await withdrawalRef.get();

            if (!withdrawal.exists) {
                throw new AppError('Withdrawal request not found', 404); // Remove error code
            }

            const withdrawalData = withdrawal.data() as CommissionWithdrawal;
            const affiliateRef = this.affiliatesRef.doc(withdrawalData.affiliateId);

            if (status === 'COMPLETED') {
                await db.runTransaction(async (transaction) => {
                    const affiliate = await transaction.get(affiliateRef);
                    const currentBalance = affiliate.data()?.availableBalance || 0;

                    if (currentBalance < withdrawalData.amount) {
                        throw new AppError('Insufficient balance', 400); // Remove error code
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
                    type: NotificationType.ORDER_STATUS, // Correct enum usage
                    status: NotificationStatus.UNREAD // Use NotificationStatus enum
                });
            } else if (status === 'REJECTED') {
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
                    type: NotificationType.ORDER_STATUS, // Correct enum usage
                    status: NotificationStatus.UNREAD // Use NotificationStatus enum
                });
            }
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError('Failed to process withdrawal', 500); // Remove error code
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
                throw new AppError('Affiliate not found', 404);
            }
            const affiliate = affiliateDoc.data() as Affiliate;

            // Get all commissions for this affiliate
            const commissionsSnapshot = await this.commissionsRef
                .where('affiliateId', '==', affiliateId)
                .get();

            const commissions = commissionsSnapshot.docs.map(doc => doc.data() as Commission);

            // Calculate pending commissions
            const pendingCommissions = commissions
                .filter(c => c.status === 'PENDING')
                .reduce((sum, c) => sum + c.commissionAmount, 0); // Use commissionAmount instead of amount

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
            const conversionRate = affiliate.referralClicks ? (orders.length / affiliate.referralClicks) * 100 : 0; // Handle 0 referral clicks

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
            throw new AppError('Failed to fetch affiliate stats', 500);
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
            throw new AppError('Failed to fetch withdrawal history', 500);
        }
    }

    async getPendingWithdrawals(
        options: {
            limit?: number;
            offset?: number;
        } = {}
    ): Promise<{
        withdrawals: (CommissionWithdrawal & { affiliate: Pick<Affiliate, 'fullName' | 'email' | 'phone'> })[];
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
                        fullName: affiliate.fullName,
                        email: affiliate.email,
                        phone: affiliate.phone
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
            throw new AppError('Failed to fetch pending withdrawals', 500);
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
                o.createdAt?.toDate().toISOString().startsWith(month) // Optional chaining for createdAt
            );

            return {
                month,
                earnings: monthCommissions.reduce((sum, c) => sum + c.commissionAmount, 0), // Use commissionAmount
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
        const totalValue = orders.reduce((sum, order) => sum + (order.totalAmount || 0), 0); // Optional chaining for totalAmount
        const uniqueCustomers = new Set(orders.map(order => order.customerId)).size;

        return {
            avgOrderValue: totalOrders > 0 ? totalValue / totalOrders : 0,
            totalOrders,
            activeCustomers: uniqueCustomers
        };
    }
}

export const affiliateService = new AffiliateService();
