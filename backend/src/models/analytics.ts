export interface RevenueMetrics {
  totalRevenue: number;
  periodRevenue: number;
  orderCount: number;
  averageOrderValue: number;
  revenueByService: Record<string, number>;
  periodStart: string;
  periodEnd: string;
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
  lastOrderDate: string;
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

export enum MetricType {
  TOTAL_REVENUE = 'TOTAL_REVENUE',
  PERIOD_REVENUE = 'PERIOD_REVENUE',
  ORDER_COUNT = 'ORDER_COUNT',
  AVERAGE_ORDER_VALUE = 'AVERAGE_ORDER_VALUE',
  REVENUE_BY_SERVICE = 'REVENUE_BY_SERVICE',
  TOTAL_CUSTOMERS = 'TOTAL_CUSTOMERS',
  ACTIVE_CUSTOMERS = 'ACTIVE_CUSTOMERS',
  CUSTOMER_RETENTION_RATE = 'CUSTOMER_RETENTION_RATE',
  TOP_CUSTOMERS = 'TOP_CUSTOMERS',
  CUSTOMERS_BY_TIER = 'CUSTOMERS_BY_TIER',
  TOTAL_AFFILIATES = 'TOTAL_AFFILIATES',
  ACTIVE_AFFILIATES = 'ACTIVE_AFFILIATES',
  TOTAL_COMMISSIONS = 'TOTAL_COMMISSIONS',
  TOP_AFFILIATES = 'TOP_AFFILIATES',
  COMMISSIONS_PER_PERIOD = 'COMMISSIONS_PER_PERIOD'
}

export enum TimeFrame {
  DAILY = 'DAILY',
  WEEKLY = 'WEEKLY',
  MONTHLY = 'MONTHLY',
  QUARTERLY = 'QUARTERLY',
  YEARLY = 'YEARLY',
  CUSTOM = 'CUSTOM'
}

export enum AggregationType {
  SUM = 'SUM',
  AVERAGE = 'AVERAGE',
  COUNT = 'COUNT',
  MIN = 'MIN',
  MAX = 'MAX'
}
