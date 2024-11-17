import { Timestamp } from 'firebase-admin/firestore';

export interface Referral {
    id: string;
    referrerId: string; // ID de l'utilisateur qui parraine
    referredId: string; // ID de l'utilisateur parrainé
    referralCode: string;
    status: 'PENDING' | 'ACTIVE' | 'EXPIRED';
    pointsEarned: number;
    ordersCount: number;
    firstOrderCompleted: boolean;
    createdAt: Timestamp;
    activatedAt?: Timestamp;
    expiresAt?: Timestamp;
}

export interface ReferralReward {
    id: string;
    referralId: string;
    referrerId: string;
    referredId: string;
    type: 'POINTS' | 'DISCOUNT' | 'CASH';
    value: number;
    status: 'PENDING' | 'CREDITED' | 'EXPIRED';
    orderId?: string;
    createdAt: Timestamp;
    creditedAt?: Timestamp;
}

export interface ReferralProgram {
    id: string;
    name: string;
    description: string;
    referrerReward: {
        type: 'POINTS' | 'DISCOUNT' | 'CASH';
        value: number;
    };
    referredReward: {
        type: 'POINTS' | 'DISCOUNT' | 'CASH';
        value: number;
    };
    minimumOrderValue: number;
    validityPeriod: number; // en jours
    isActive: boolean;
    createdAt: Timestamp;
    updatedAt: Timestamp;
}
