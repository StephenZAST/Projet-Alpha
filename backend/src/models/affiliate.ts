import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

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
    preferredMethod: string; // Changed to string for now
    mobileMoneyNumber?: string;
    bankInfo?: {
      accountNumber: string;
      bankName: string;
      branchName?: string;
    };
  };
  orderPreferences: {
    allowedOrderTypes: string[];
    allowedPaymentMethods: string[]; // Changed to string for now
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
  paymentMethod: string; // Changed to string for now
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

// Use Supabase to store affiliate data
const affiliatesTable = 'affiliates';

// Function to get affiliate data
export async function getAffiliate(id: string): Promise<Affiliate | null> {
  const { data, error } = await supabase.from(affiliatesTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch affiliate', 'INTERNAL_SERVER_ERROR');
  }

  return data as Affiliate;
}

// Function to create affiliate
export async function createAffiliate(affiliateData: Affiliate): Promise<Affiliate> {
  const { data, error } = await supabase.from(affiliatesTable).insert([affiliateData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create affiliate', 'INTERNAL_SERVER_ERROR');
  }

  return data as Affiliate;
}

// Function to update affiliate
export async function updateAffiliate(id: string, affiliateData: Partial<Affiliate>): Promise<Affiliate> {
  const currentAffiliate = await getAffiliate(id);

  if (!currentAffiliate) {
    throw new AppError(404, 'Affiliate not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(affiliatesTable).update(affiliateData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update affiliate', 'INTERNAL_SERVER_ERROR');
  }

  return data as Affiliate;
}

// Function to delete affiliate
export async function deleteAffiliate(id: string): Promise<void> {
  const affiliate = await getAffiliate(id);

  if (!affiliate) {
    throw new AppError(404, 'Affiliate not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(affiliatesTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete affiliate', 'INTERNAL_SERVER_ERROR');
  }
}

// Use Supabase to store commission withdrawal data
const commissionWithdrawalsTable = 'commissionWithdrawals';

// Function to get commission withdrawal data
export async function getCommissionWithdrawal(id: string): Promise<CommissionWithdrawal | null> {
  const { data, error } = await supabase.from(commissionWithdrawalsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch commission withdrawal', 'INTERNAL_SERVER_ERROR');
  }

  return data as CommissionWithdrawal;
}

// Function to create commission withdrawal
export async function createCommissionWithdrawal(withdrawalData: CommissionWithdrawal): Promise<CommissionWithdrawal> {
  const { data, error } = await supabase.from(commissionWithdrawalsTable).insert([withdrawalData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create commission withdrawal', 'INTERNAL_SERVER_ERROR');
  }

  return data as CommissionWithdrawal;
}

// Function to update commission withdrawal
export async function updateCommissionWithdrawal(id: string, withdrawalData: Partial<CommissionWithdrawal>): Promise<CommissionWithdrawal> {
  const currentWithdrawal = await getCommissionWithdrawal(id);

  if (!currentWithdrawal) {
    throw new AppError(404, 'Commission withdrawal not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(commissionWithdrawalsTable).update(withdrawalData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update commission withdrawal', 'INTERNAL_SERVER_ERROR');
  }

  return data as CommissionWithdrawal;
}

// Function to delete commission withdrawal
export async function deleteCommissionWithdrawal(id: string): Promise<void> {
  const withdrawal = await getCommissionWithdrawal(id);

  if (!withdrawal) {
    throw new AppError(404, 'Commission withdrawal not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(commissionWithdrawalsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete commission withdrawal', 'INTERNAL_SERVER_ERROR');
  }
}
