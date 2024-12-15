import { supabase } from '../config';
import { RevenueMetrics, CustomerMetrics, AffiliateMetrics, AffiliateSummary } from '../models/analytics';
import { AppError, errorCodes } from '../utils/errors';
import { getAnalytics, createAnalytics, updateAnalytics, deleteAnalytics } from './analyticsService/analyticsManagement';

export class AnalyticsService {
  private readonly analyticsTable = 'analytics';

  async getRevenueMetrics(startDate: Date, endDate: Date): Promise<RevenueMetrics> {
    try {
      const { data: orders, error: ordersError } = await supabase
        .from('orders')
        .select('*')
        .gte('createdAt', startDate.toISOString())
        .lte('createdAt', endDate.toISOString());

      if (ordersError) {
        throw new AppError(500, 'Failed to fetch orders', 'REVENUE_METRICS_FETCH_FAILED');
      }

      const totalRevenue = (orders || []).reduce((sum, order) => sum + order.totalAmount, 0);
      const averageOrderValue = totalRevenue / (orders || []).length || 0;

      const revenueByService = (orders || []).reduce((acc, order) => {
        order.items.forEach((item: { service: string | number; totalPrice: any; }) => {
          acc[item.service] = (acc[item.service] || 0) + item.totalPrice;
        });
        return acc;
      }, {} as Record<string, number>);

      return {
        totalRevenue,
        periodRevenue: totalRevenue,
        orderCount: (orders || []).length,
        averageOrderValue,
        revenueByService,
        periodStart: startDate.toISOString(),
        periodEnd: endDate.toISOString()
      };
    } catch (error) {
      throw new AppError(500, 'Failed to fetch revenue metrics', 'REVENUE_METRICS_FETCH_FAILED');
    }
  }

  async getCustomerMetrics(): Promise<CustomerMetrics> {
    try {
      const { data: customers, error: customersError } = await supabase
        .from('users')
        .select('*')
        .eq('role', 'customer');

      if (customersError) {
        throw new AppError(500, 'Failed to fetch customers', 'CUSTOMER_METRICS_FETCH_FAILED');
      }

      const activeCustomers = customers.filter((customer) => 
        customer.lastOrderDate && 
        new Date(customer.lastOrderDate) >= new Date(Date.now() - 90 * 24 * 60 * 60 * 1000)
      );

      const topCustomers = customers
        .sort((a, b) => b.totalSpent - a.totalSpent)
        .slice(0, 10)
        .map((customer) => ({
          userId: customer.id,
          totalSpent: customer.totalSpent,
          orderCount: customer.orderCount,
          loyaltyTier: customer.loyaltyTier,
          lastOrderDate: customer.lastOrderDate
        }));

      return {
        totalCustomers: customers.length,
        activeCustomers: activeCustomers.length,
        customerRetentionRate: (activeCustomers.length / customers.length) * 100,
        topCustomers,
        customersByTier: this.groupCustomersByTier(customers)
      };
    } catch (error) {
      throw new AppError(500, 'Failed to fetch customer metrics', 'CUSTOMER_METRICS_FETCH_FAILED');
    }
  }

  async getAffiliateMetrics(startDate: Date, endDate: Date): Promise<AffiliateMetrics> {
    try {
      const { data: affiliates, error: affiliatesError } = await supabase
        .from('affiliates')
        .select('*');

      if (affiliatesError) {
        throw new AppError(500, 'Failed to fetch affiliates', 'AFFILIATE_METRICS_FETCH_FAILED');
      }

      const topAffiliates = await this.calculateTopAffiliates(affiliates, startDate, endDate);

      return {
        totalAffiliates: affiliates.length,
        activeAffiliates: affiliates.filter((a) => a.activeCustomers > 0).length,
        totalCommissions: affiliates.reduce((sum, a) => sum + a.totalCommission, 0),
        topAffiliates,
        commissionsPerPeriod: await this.calculateCommissionsPerPeriod(startDate, endDate)
      };
    } catch (error) {
      throw new AppError(500, 'Failed to fetch affiliate metrics', 'AFFILIATE_METRICS_FETCH_FAILED');
    }
  }

  private async calculateTopAffiliates(affiliates: { id: string; referralCount: number; totalCommission: number; activeCustomers: number; performance: number; }[], startDate: Date, endDate: Date): Promise<AffiliateSummary[]> {
    // Implementation for calculating top affiliate performance
    return [];
  }

  private async calculateCommissionsPerPeriod(startDate: Date, endDate: Date): Promise<Record<string, number>> {
    // Implementation for calculating commissions per period
    return {};
  }

  private groupCustomersByTier(customers: { loyaltyTier: string; }[]): Record<string, number> {
    return customers.reduce((acc, customer) => {
      acc[customer.loyaltyTier] = (acc[customer.loyaltyTier] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);
  }
}

export const analyticsService = new AnalyticsService();

export { getAnalytics, createAnalytics, updateAnalytics, deleteAnalytics } from './analyticsService/analyticsManagement';
