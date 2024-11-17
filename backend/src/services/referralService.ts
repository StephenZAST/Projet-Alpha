import { db } from '../config/firebase';
import { Referral, ReferralReward, ReferralProgram } from '../models/referral';
import { generateUniqueCode } from '../utils/codeGenerator';
import { AppError } from '../utils/errors';
import { Timestamp } from 'firebase-admin/firestore';
import { NotificationService } from './notificationService';

export class ReferralService {
    private referralsRef = db.collection('referrals');
    private rewardsRef = db.collection('referral-rewards');
    private programsRef = db.collection('referral-programs');
    private notificationService: NotificationService;

    constructor() {
        this.notificationService = new NotificationService();
    }

    async createReferral(referrerId: string, referredEmail: string): Promise<Referral> {
        // Vérifier si l'email a déjà été parrainé
        const existingReferral = await this.referralsRef
            .where('referredEmail', '==', referredEmail)
            .get();

        if (!existingReferral.empty) {
            throw new AppError(400, 'This email has already been referred');
        }

        const referral: Omit<Referral, 'id'> = {
            referrerId,
            referredId: '', // Sera mis à jour lors de l'inscription
            referralCode: await generateUniqueCode(8),
            status: 'PENDING',
            pointsEarned: 0,
            ordersCount: 0,
            firstOrderCompleted: false,
            createdAt: Timestamp.now()
        };

        const docRef = await this.referralsRef.add(referral);
        
        // Envoyer un email d'invitation
        await this.notificationService.sendReferralInvitation(referredEmail, referral.referralCode);

        return { ...referral, id: docRef.id } as Referral;
    }

    async activateReferral(referralCode: string, referredId: string): Promise<void> {
        const referralQuery = await this.referralsRef
            .where('referralCode', '==', referralCode)
            .where('status', '==', 'PENDING')
            .get();

        if (referralQuery.empty) {
            throw new AppError(404, 'Invalid or expired referral code');
        }

        const referralDoc = referralQuery.docs[0];
        const referral = referralDoc.data() as Referral;

        // Activer le parrainage
        await referralDoc.ref.update({
            referredId,
            status: 'ACTIVE',
            activatedAt: Timestamp.now(),
            expiresAt: Timestamp.fromDate(new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)) // 30 jours
        });

        // Créer les récompenses initiales
        await this.createInitialRewards(referralDoc.id, referral.referrerId, referredId);
    }

    private async createInitialRewards(
        referralId: string,
        referrerId: string,
        referredId: string
    ): Promise<void> {
        const program = await this.getActiveProgram();

        // Récompense pour le parrain
        const referrerReward: Omit<ReferralReward, 'id'> = {
            referralId,
            referrerId,
            referredId,
            type: program.referrerReward.type,
            value: program.referrerReward.value,
            status: 'PENDING',
            createdAt: Timestamp.now()
        };

        // Récompense pour le parrainé
        const referredReward: Omit<ReferralReward, 'id'> = {
            referralId,
            referrerId,
            referredId,
            type: program.referredReward.type,
            value: program.referredReward.value,
            status: 'PENDING',
            createdAt: Timestamp.now()
        };

        await Promise.all([
            this.rewardsRef.add(referrerReward),
            this.rewardsRef.add(referredReward)
        ]);
    }

    async processFirstOrderReward(referralId: string, orderId: string): Promise<void> {
        const referralRef = this.referralsRef.doc(referralId);
        const referral = await referralRef.get();

        if (!referral.exists) {
            throw new AppError(404, 'Referral not found');
        }

        if (referral.data()?.firstOrderCompleted) {
            throw new AppError(400, 'First order reward already processed');
        }

        // Mettre à jour les récompenses
        const rewards = await this.rewardsRef
            .where('referralId', '==', referralId)
            .where('status', '==', 'PENDING')
            .get();

        const batch = db.batch();
        
        rewards.docs.forEach(doc => {
            batch.update(doc.ref, {
                status: 'CREDITED',
                orderId,
                creditedAt: Timestamp.now()
            });
        });

        // Mettre à jour le parrainage
        batch.update(referralRef, {
            firstOrderCompleted: true,
            ordersCount: 1,
            updatedAt: Timestamp.now()
        });

        await batch.commit();
    }

    private async getActiveProgram(): Promise<ReferralProgram> {
        const programQuery = await this.programsRef
            .where('isActive', '==', true)
            .limit(1)
            .get();

        if (programQuery.empty) {
            throw new AppError(404, 'No active referral program found');
        }

        return { ...programQuery.docs[0].data(), id: programQuery.docs[0].id } as ReferralProgram;
    }

    async getReferralStats(userId: string): Promise<{
        totalReferrals: number;
        activeReferrals: number;
        completedReferrals: number;
        totalRewards: number;
    }> {
        const referralsQuery = await this.referralsRef
            .where('referrerId', '==', userId)
            .get();

        const referrals = referralsQuery.docs.map(doc => doc.data() as Referral);

        return {
            totalReferrals: referrals.length,
            activeReferrals: referrals.filter(r => r.status === 'ACTIVE').length,
            completedReferrals: referrals.filter(r => r.firstOrderCompleted).length,
            totalRewards: 0 // À calculer en fonction des récompenses créditées
        };
    }
}
