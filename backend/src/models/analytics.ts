import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

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

// Use Supabase to store analytics data
const analyticsTable = 'analytics';

// Function to get analytics data
export async function getAnalytics(id: string): Promise<RevenueMetrics | CustomerMetrics | AffiliateMetrics | null> {
  const { data, error } = await supabase.from(analyticsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch analytics', 'INTERNAL_SERVER_ERROR');
  }

  return data as RevenueMetrics | CustomerMetrics | AffiliateMetrics;
}

// Function to create analytics
export async function createAnalytics(analyticsData: RevenueMetrics | CustomerMetrics | AffiliateMetrics): Promise<RevenueMetrics | CustomerMetrics | AffiliateMetrics> {
  const { data, error } = await supabase.from(analyticsTable).insert([analyticsData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create analytics', 'INTERNAL_SERVER_ERROR');
  }

  return data as RevenueMetrics | CustomerMetrics | AffiliateMetrics;
}

// Function to update analytics
export async function updateAnalytics(id: string, analyticsData: Partial<RevenueMetrics | CustomerMetrics | AffiliateMetrics>): Promise<RevenueMetrics | CustomerMetrics | AffiliateMetrics> {
  const currentAnalytics = await getAnalytics(id);

  if (!currentAnalytics) {
    throw new AppError(404, 'Analytics not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(analyticsTable).update(analyticsData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update analytics', 'INTERNAL_SERVER_ERROR');
  }

  return data as RevenueMetrics | CustomerMetrics | AffiliateMetrics;
}

// Function to delete analytics
export async function deleteAnalytics(id: string): Promise<void> {
  const analytics = await getAnalytics(id);

  if (!analytics) {
    throw new AppError(404, 'Analytics not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(analyticsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete analytics', 'INTERNAL_SERVER_ERROR');
  }
}
