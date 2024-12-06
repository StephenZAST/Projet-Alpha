import { Timestamp } from 'firebase-admin/firestore';

export enum AffiliateStatus {
    PENDING = 'PENDING',
    ACTIVE = 'ACTIVE',
    SUSPENDED = 'SUSPENDED'
}

export enum CommissionType {
    FIXED = 'FIXED',
    PERCENTAGE = 'PERCENTAGE'
}

export enum PayoutStatus {
    PENDING = 'PENDING',
    COMPLETED = 'COMPLETED',
    REJECTED = 'REJECTED'
}

export enum PaymentMethod {
    MOBILE_MONEY = 'MOBILE_MONEY',
    BANK_TRANSFER = 'BANK_TRANSFER',
    CASH = 'CASH'
}

export interface PaymentInfo {
    preferredMethod: PaymentMethod;
    mobileMoneyNumber?: string;     // Pour Orange Money, Wave, etc.
    bankInfo?: {
        bankName: string;
        accountNumber: string;
        accountHolder: string;
    };
}

export interface Affiliate {
    id: string;
    fullName: string;
    email: string;
    phone: string;
    status: AffiliateStatus;
    paymentInfo: PaymentInfo;
    commissionSettings: {
        type: 'PERCENTAGE';
        value: number;
    };
    totalEarnings: number;
    availableBalance: number;
    referralCode: string;
    referralClicks: number; // Add referralClicks property
    createdAt: Timestamp;
    updatedAt: Timestamp;
}

export interface CommissionWithdrawal {
    id: string;
    affiliateId: string;
    amount: number;
    paymentMethod: PaymentMethod;
    paymentDetails: {
        mobileMoneyNumber?: string;
        bankInfo?: {
            bankName: string;
            accountNumber: string;
        };
    };
    status: 'PENDING' | 'COMPLETED';
    processedBy?: string;
    notes?: string;
    requestedAt: Timestamp;
    processedAt?: Timestamp;
}
