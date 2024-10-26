export interface RevenueMetrics {
  totalRevenue: number;
  periodRevenue: number;
  orderCount: number;
  averageOrderValue: number;
  revenueByService: Record<string, number>;
  periodStart: Date;
  periodEnd: Date;
}

export interface CustomerMetrics {
  totalCustomers: number;
  activeCustomers: number;
  customerRetentionRate: number;
  topCustomers: CustomerSummary[];
  customersByTier: Record<string, number>;
}

export interface CustomerSummary {
  userId: string;
  totalSpent: number;
  orderCount: number;
  loyaltyTier: string;
  lastOrderDate: Date;
}

export interface AffiliateMetrics {
  totalAffiliates: number;
  activeAffiliates: number;
  totalCommissions: number;
  topAffiliates: AffiliateSummary[];
  commissionsPerPeriod: Record<string, number>;
}

export interface AffiliateSummary {
  affiliateId: string;
  referralCount: number;
  totalCommission: number;
  activeCustomers: number;
  performance: number;
}
