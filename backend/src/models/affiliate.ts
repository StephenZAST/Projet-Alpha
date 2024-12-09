import { PaymentMethod } from './order';

export enum CommissionType {
  FIXED,
  PERCENTAGE
}

export enum PayoutStatus {
  PENDING = 'PENDING',
  COMPLETED = 'COMPLETED',
  FAILED = 'FAILED'
}

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
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  PENDING = 'PENDING'
}

export interface Affiliate {
  id?: string;
  firstName: string;
  lastName: string;
  email: string;
  phoneNumber: string;
  address: string;
  status: AffiliateStatus;
  commissionRate: number;
  paymentInfo: {
    preferredMethod: PaymentMethod;
    mobileMoneyNumber?: string;
    bankInfo?: {
      accountNumber: string;
      bankName: string;
      branchName?: string;
    };
  };
  orderPreferences: {
    allowedOrderTypes: string[];
    allowedPaymentMethods: PaymentMethod[];
  };
  availableBalance: number;
  referralCode: string;
  referralClicks: number;
  totalEarnings: number;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface CommissionWithdrawal {
  id?: string;
  affiliateId: string;
  amount: number;
  paymentMethod: PaymentMethod;
  paymentDetails: {
    mobileMoneyNumber: string | undefined;
    bankInfo: {
        accountNumber: string;
        bankName: string;
        branchName?: string;
    } | undefined;
};
  status: PayoutStatus;
  requestedAt: Date;
  processedAt: Date | null;
  processedBy: string | null;
  createdAt?: Date;
  updatedAt?: Date;
}
