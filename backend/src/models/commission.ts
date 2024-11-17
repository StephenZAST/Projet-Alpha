import { Timestamp } from 'firebase-admin/firestore';

export interface Commission {
    id: string;
    affiliateId: string;
    clientId: string;         // ID du client apporté
    orderId: string;
    orderAmount: number;
    commissionAmount: number;
    status: 'PENDING' | 'APPROVED' | 'PAID';
    createdAt: Timestamp;
    approvedAt?: Timestamp;
    paidAt?: Timestamp;
}

export interface CommissionRule {
    id: string;
    name: string;
    description: string;
    type: 'PERCENTAGE';       // Simplifié à pourcentage uniquement
    value: number;           // Valeur du pourcentage
    minimumOrderValue: number;
    isActive: boolean;
    createdAt: Timestamp;
    updatedAt: Timestamp;
}
