import { db } from '../config/firebase';
import { Commission, CommissionRule } from '../models/commission';
import { AppError } from '../utils/errors';
import { Timestamp } from 'firebase-admin/firestore';
import { NotificationService } from './notificationService';

export class CommissionService {
    private commissionsRef = db.collection('commissions');
    private rulesRef = db.collection('commission-rules');
    private affiliatesRef = db.collection('affiliates');
    private notificationService: NotificationService;

    constructor() {
        this.notificationService = new NotificationService();
    }

    async calculateCommission(
        affiliateId: string,
        clientId: string,
        orderId: string,
        orderAmount: number
    ): Promise<Commission> {
        // Récupérer la règle de commission active
        const rule = await this.getActiveRule();

        if (orderAmount < rule.minimumOrderValue) {
            throw new AppError(400, `Order amount below minimum value of ${rule.minimumOrderValue}`);
        }

        // Calculer la commission (toujours en pourcentage)
        const commissionAmount = (orderAmount * rule.value) / 100;

        const commission: Omit<Commission, 'id'> = {
            affiliateId,
            clientId,
            orderId,
            orderAmount,
            commissionAmount,
            status: 'PENDING',
            createdAt: Timestamp.now()
        };

        const docRef = await this.commissionsRef.add(commission);

        // Mettre à jour les statistiques de l'affilié
        await this.updateAffiliateStats(affiliateId, commissionAmount);

        return { ...commission, id: docRef.id } as Commission;
    }

    private async updateAffiliateStats(affiliateId: string, commissionAmount: number): Promise<void> {
        const affiliateRef = this.affiliatesRef.doc(affiliateId);
        
        await affiliateRef.update({
            totalEarnings: db.FieldValue.increment(commissionAmount),
            availableBalance: db.FieldValue.increment(commissionAmount),
            updatedAt: Timestamp.now()
        });
    }

    async approveCommission(commissionId: string): Promise<void> {
        const commissionRef = this.commissionsRef.doc(commissionId);
        const commission = await commissionRef.get();

        if (!commission.exists) {
            throw new AppError(404, 'Commission not found');
        }

        if (commission.data()?.status !== 'PENDING') {
            throw new AppError(400, 'Commission is not in pending status');
        }

        await commissionRef.update({
            status: 'APPROVED',
            approvedAt: Timestamp.now()
        });

        // Notifier l'affilié
        await this.notificationService.sendCommissionApprovalNotification(
            commission.data()?.affiliateId,
            commission.data()?.commissionAmount
        );
    }

    async getCommissionsByAffiliate(affiliateId: string): Promise<Commission[]> {
        const commissionsQuery = await this.commissionsRef
            .where('affiliateId', '==', affiliateId)
            .orderBy('createdAt', 'desc')
            .get();

        return commissionsQuery.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        })) as Commission[];
    }

    async getCommissionsByOrder(orderId: string): Promise<Commission[]> {
        const commissionsQuery = await this.commissionsRef
            .where('orderId', '==', orderId)
            .get();

        return commissionsQuery.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        })) as Commission[];
    }

    private async getActiveRule(): Promise<CommissionRule> {
        const ruleQuery = await this.rulesRef
            .where('isActive', '==', true)
            .limit(1)
            .get();

        if (ruleQuery.empty) {
            // Règle par défaut si aucune n'est configurée
            return {
                id: 'default',
                name: 'Default Rule',
                description: 'Default commission rule',
                type: 'PERCENTAGE',
                value: 10, // 10% par défaut
                minimumOrderValue: 1000, // 1000 FCFA minimum
                isActive: true,
                createdAt: Timestamp.now(),
                updatedAt: Timestamp.now()
            };
        }

        return { ...ruleQuery.docs[0].data(), id: ruleQuery.docs[0].id } as CommissionRule;
    }

    async updateCommissionRule(
        ruleId: string,
        updates: Partial<Omit<CommissionRule, 'id' | 'createdAt'>>
    ): Promise<void> {
        const ruleRef = this.rulesRef.doc(ruleId);
        const rule = await ruleRef.get();

        if (!rule.exists) {
            throw new AppError(404, 'Commission rule not found');
        }

        await ruleRef.update({
            ...updates,
            updatedAt: Timestamp.now()
        });
    }
}