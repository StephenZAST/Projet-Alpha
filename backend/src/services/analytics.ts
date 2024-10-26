import { db } from './firebase';
import { RevenueMetrics, CustomerMetrics, AffiliateMetrics } from '../models/analytics';

// Add interface for OrderItem
interface OrderItem {
  service: string;
  totalPrice: number;
}

// Add interface for Order
interface Order {
  totalAmount: number;
  items: OrderItem[];
}

// Add interface for Customer
interface Customer {
  id: string;
  lastOrderDate: Date;
  totalSpent: number;
  orderCount: number;
  loyaltyTier: string;
}

// Add interface for Affiliate
interface Affiliate {
  id: string;
  activeCustomers: number;
  totalCommission: number;
}

export class AnalyticsService {
  private readonly ordersRef = db.collection('orders');
  private readonly usersRef = db.collection('users');
  private readonly affiliatesRef = db.collection('affiliates');

  async getRevenueMetrics(startDate: Date, endDate: Date): Promise<RevenueMetrics> {
    const ordersSnapshot = await this.ordersRef
      .where('createdAt', '>=', startDate)
      .where('createdAt', '<=', endDate)
      .get();

    const orders = ordersSnapshot.docs.map(doc => doc.data() as Order);
    
    const totalRevenue = orders.reduce((sum, order) => sum + order.totalAmount, 0);
    const averageOrderValue = totalRevenue / orders.length || 0;
    
    const revenueByService = orders.reduce((acc, order) => {
      order.items.forEach((item: OrderItem) => {
        acc[item.service] = (acc[item.service] || 0) + item.totalPrice;
      });
      return acc;
    }, {} as Record<string, number>);

    return {
      totalRevenue,
      periodRevenue: totalRevenue,
      orderCount: orders.length,
      averageOrderValue,
      revenueByService,
      periodStart: startDate,
      periodEnd: endDate
    };
  }

  async getCustomerMetrics(): Promise<CustomerMetrics> {
    const customersSnapshot = await this.usersRef
      .where('role', '==', 'customer')
      .get();

    const customers = customersSnapshot.docs.map(doc => doc.data() as Customer);
    
    const activeCustomers = customers.filter(customer => 
      customer.lastOrderDate && 
      new Date(customer.lastOrderDate) >= new Date(Date.now() - 90 * 24 * 60 * 60 * 1000)
    );

    const topCustomers = customers
      .sort((a, b) => b.totalSpent - a.totalSpent)
      .slice(0, 10)
      .map(customer => ({
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
  }

  async getAffiliateMetrics(startDate: Date, endDate: Date): Promise<AffiliateMetrics> {
    const affiliatesSnapshot = await this.affiliatesRef.get();
    const affiliates = affiliatesSnapshot.docs.map(doc => doc.data() as Affiliate);

    const topAffiliates = await this.calculateTopAffiliates(affiliates, startDate, endDate);

    return {
      totalAffiliates: affiliates.length,
      activeAffiliates: affiliates.filter(a => a.activeCustomers > 0).length,
      totalCommissions: affiliates.reduce((sum, a) => sum + a.totalCommission, 0),
      topAffiliates,
      commissionsPerPeriod: await this.calculateCommissionsPerPeriod(startDate, endDate)
    };
  }

  private async calculateTopAffiliates(affiliates: any[], startDate: Date, endDate: Date) {
    // Implementation for calculating top affiliate performance
    return [];
  }

  private async calculateCommissionsPerPeriod(startDate: Date, endDate: Date) {
    // Implementation for calculating commissions per period
    return {};
  }

  private groupCustomersByTier(customers: any[]) {
    return customers.reduce((acc, customer) => {
      acc[customer.loyaltyTier] = (acc[customer.loyaltyTier] || 0) + 1;
      return acc;
    }, {});
  }
}