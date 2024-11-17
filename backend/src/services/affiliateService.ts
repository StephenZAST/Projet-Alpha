import { db } from '../config/firebase';
import { Affiliate, AffiliateStatus, PaymentMethod, CommissionWithdrawal } from '../models/affiliate';
import { Commission } from '../models/commission';
import { generateUniqueCode } from '../utils/codeGenerator';
import { AppError } from '../utils/errors';
import { Timestamp } from 'firebase-admin/firestore';
import { NotificationService } from './notificationService';

export class AffiliateService {
    private affiliatesRef = db.collection('affiliates');
    private commissionsRef = db.collection('commissions');
    private withdrawalsRef = db.collection('commission-withdrawals');
    private notificationService: NotificationService;

    constructor() {
        this.notificationService = new NotificationService();
    }

    async createAffiliate(
        fullName: string,
        email: string,
        phone: string,
        paymentInfo: Affiliate['paymentInfo']
    ): Promise<Affiliate> {
        // Vérifier si l'email est déjà utilisé
        const existingAffiliate = await this.affiliatesRef
            .where('email', '==', email)
            .get();

        if (!existingAffiliate.empty) {
            throw new AppError(400, 'Email already registered as affiliate');
        }

        const affiliate: Omit<Affiliate, 'id'> = {
            fullName,
            email,
            phone,
            status: AffiliateStatus.PENDING,
            paymentInfo,
            commissionSettings: {
                type: 'PERCENTAGE',
                value: 10, // 10% par défaut
            },
            totalEarnings: 0,
            availableBalance: 0,
            referralCode: await generateUniqueCode(8),
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now()
        };

        const docRef = await this.affiliatesRef.add(affiliate);
        return { ...affiliate, id: docRef.id } as Affiliate;
    }

    async approveAffiliate(affiliateId: string): Promise<void> {
        const affiliateRef = this.affiliatesRef.doc(affiliateId);
        const affiliate = await affiliateRef.get();

        if (!affiliate.exists) {
            throw new AppError(404, 'Affiliate not found');
        }

        if (affiliate.data()?.status === AffiliateStatus.ACTIVE) {
            throw new AppError(400, 'Affiliate is already active');
        }

        await affiliateRef.update({
            status: AffiliateStatus.ACTIVE,
            updatedAt: Timestamp.now()
        });

        // Notifier l'affilié
        await this.notificationService.sendAffiliateApprovalNotification(affiliateId);
    }

    async requestWithdrawal(
        affiliateId: string,
        amount: number,
        paymentMethod: PaymentMethod
    ): Promise<CommissionWithdrawal> {
        const affiliateRef = this.affiliatesRef.doc(affiliateId);
        const affiliate = await affiliateRef.get();

        if (!affiliate.exists) {
            throw new AppError(404, 'Affiliate not found');
        }

        const affiliateData = affiliate.data() as Affiliate;

        if (affiliateData.availableBalance < amount) {
            throw new AppError(400, 'Insufficient balance');
        }

        if (amount < 1000) { // Minimum 1000 FCFA
            throw new AppError(400, 'Minimum withdrawal amount is 1000 FCFA');
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
    }

    async processWithdrawal(
        withdrawalId: string,
        adminId: string,
        status: 'COMPLETED',
        notes?: string
    ): Promise<void> {
        const withdrawalRef = this.withdrawalsRef.doc(withdrawalId);
        const withdrawal = await withdrawalRef.get();

        if (!withdrawal.exists) {
            throw new AppError(404, 'Withdrawal request not found');
        }

        const withdrawalData = withdrawal.data() as CommissionWithdrawal;
        const affiliateRef = this.affiliatesRef.doc(withdrawalData.affiliateId);

        await db.runTransaction(async (transaction) => {
            const affiliate = await transaction.get(affiliateRef);
            const currentBalance = affiliate.data()?.availableBalance || 0;

            if (currentBalance < withdrawalData.amount) {
                throw new AppError(400, 'Insufficient balance');
            }

            // Mettre à jour le solde de l'affilié
            transaction.update(affiliateRef, {
                availableBalance: currentBalance - withdrawalData.amount,
                updatedAt: Timestamp.now()
            });

            // Marquer le retrait comme complété
            transaction.update(withdrawalRef, {
                status: 'COMPLETED',
                processedBy: adminId,
                processedAt: Timestamp.now(),
                notes: notes
            });
        });

        // Notifier l'affilié
        await this.notificationService.sendWithdrawalCompletedNotification(
            withdrawalData.affiliateId,
            withdrawalData.amount
        );
    }

    async getAffiliateStats(affiliateId: string): Promise<{
        totalCommissions: number;
        pendingCommissions: number;
        totalEarnings: number;
        availableBalance: number;
        clientsReferred: number;
    }> {
        const affiliate = await this.affiliatesRef.doc(affiliateId).get();
        
        if (!affiliate.exists) {
            throw new AppError(404, 'Affiliate not found');
        }

        const commissions = await this.commissionsRef
            .where('affiliateId', '==', affiliateId)
            .get();

        const commissionsData = commissions.docs.map(doc => doc.data() as Commission);

        return {
            totalCommissions: commissionsData.length,
            pendingCommissions: commissionsData.filter(c => c.status === 'PENDING').length,
            totalEarnings: affiliate.data()?.totalEarnings || 0,
            availableBalance: affiliate.data()?.availableBalance || 0,
            clientsReferred: new Set(commissionsData.map(c => c.clientId)).size
        };
    }

    // Pour le dashboard admin/secrétaire
    async getPendingWithdrawals(): Promise<CommissionWithdrawal[]> {
        const withdrawals = await this.withdrawalsRef
            .where('status', '==', 'PENDING')
            .orderBy('requestedAt', 'desc')
            .get();

        return withdrawals.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        })) as CommissionWithdrawal[];
    }

    async getWithdrawalHistory(affiliateId: string): Promise<CommissionWithdrawal[]> {
        const withdrawals = await this.withdrawalsRef
            .where('affiliateId', '==', affiliateId)
            .orderBy('requestedAt', 'desc')
            .get();

        return withdrawals.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        })) as CommissionWithdrawal[];
    }
}
