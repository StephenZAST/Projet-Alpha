import { AppError, errorCodes } from '../utils/errors';
import { PaymentMethod } from '../models/order';

export enum CommissionType {
  FIXED = 'FIXED',
  PERCENTAGE = 'PERCENTAGE'
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
  createdAt?: string;
  updatedAt?: string;
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
  requestedAt: string;
  processedAt: string | null;
  processedBy: string | null;
  createdAt?: string;
  updatedAt?: string;
}

export { PaymentMethod };
