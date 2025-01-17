export type AffiliateStatus = 'active' | 'pending' | 'suspended';

export interface Affiliate {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  status: AffiliateStatus;
  earnings: number;
  referralCode: string;
  createdAt: string;
  totalReferrals?: number;
  monthlyEarnings?: number;
}

export interface AffiliateMetrics {
  totalReferrals: number;
  monthlyEarnings: {
    month: string;
    amount: number;
  }[];
  conversionRate: number;
  totalOrders: number;
  activeReferrals: number;
}
