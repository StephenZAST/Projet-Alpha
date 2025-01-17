export interface DashboardMetrics {
  orders?: number;
  revenue?: number;
  users?: number;
  affiliates?: number;
  deliveries?: number;
  dailyOrders?: number;
  monthlyRevenue?: number;
  activeUsers?: number;
  pendingDeliveries?: number;
  completedDeliveries?: number;
}

export interface MetricCardData {
  title: string;
  value: string | number;
  change?: number;
  trend?: 'up' | 'down';
}
