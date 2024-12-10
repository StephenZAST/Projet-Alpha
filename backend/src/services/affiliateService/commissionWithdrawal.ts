import { db, Timestamp } from '../../config/firebase';
import { Affiliate, CommissionWithdrawal, PayoutStatus } from '../../models/affiliate';
import { AppError, errorCodes } from '../../utils/errors';
import { PaymentMethod } from '../../models/order';
import { notificationService, NotificationType, NotificationStatus } from '../notificationService';

const affiliatesRef = db.collection('affiliates');
const withdrawalsRef = db.collection('commission-withdrawals');

export async function requestCommissionWithdrawal(
    affiliateId: string,
    amount: number,
    paymentMethod: PaymentMethod
): Promise<CommissionWithdrawal> {
    try {
        const affiliateRef = affiliatesRef.doc(affiliateId);
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
            processedBy: null,
            createdAt: new Date(),
            updatedAt: new Date()
        };

        const docRef = await withdrawalsRef.add(withdrawal);
        return { ...withdrawal, id: docRef.id } as CommissionWithdrawal;
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError(500, 'Failed to create withdrawal request', errorCodes.WITHDRAWAL_REQUEST_NOT_FOUND);
    }
}

export async function getCommissionWithdrawals(): Promise<CommissionWithdrawal[]> {
    try {
        const snapshot = await withdrawalsRef.get();
        return snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        })) as CommissionWithdrawal[];
    } catch (error) {
        throw new AppError(500, 'Failed to get commission withdrawals', errorCodes.WITHDRAWAL_HISTORY_FETCH_FAILED);
    }
}

export async function updateCommissionWithdrawalStatus(withdrawalId: string, status: PayoutStatus): Promise<CommissionWithdrawal> {
    try {
        const withdrawalRef = withdrawalsRef.doc(withdrawalId);
        const withdrawal = await withdrawalRef.get();

        if (!withdrawal.exists) {
            throw new AppError(404, 'Withdrawal request not found', errorCodes.WITHDRAWAL_REQUEST_NOT_FOUND);
        }

        await withdrawalRef.update({
            status,
            updatedAt: Timestamp.now()
        });

        return {
            id: withdrawalId,
            ...withdrawal.data(),
            status
        } as CommissionWithdrawal;
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError(500, 'Failed to update commission withdrawal status', errorCodes.WITHDRAWAL_PROCESSING_FAILED);
    }
}

export async function processWithdrawal(
    withdrawalId: string,
    adminId: string,
    status: PayoutStatus,
    notes?: string
): Promise<void> {
    try {
        const withdrawalRef = withdrawalsRef.doc(withdrawalId);
        const withdrawal = await withdrawalRef.get();

        if (!withdrawal.exists) {
            throw new AppError(404, 'Withdrawal request not found', errorCodes.WITHDRAWAL_REQUEST_NOT_FOUND);
        }

        const withdrawalData = withdrawal.data() as CommissionWithdrawal;
        const affiliateRef = affiliatesRef.doc(withdrawalData.affiliateId);

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

export async function getWithdrawalHistory(
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
        let query = withdrawalsRef
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

export async function getPendingWithdrawals(
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
        let query = withdrawalsRef
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
            const affiliateDoc = await affiliatesRef.doc(withdrawal.affiliateId).get();
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
