export interface ChartData {
  name: string;
  value: number;
  date: string;
}

export interface AdminMetric {
  id: string;
  title: string;
  value: string | number;
  chartData: ChartData[];
  chartType: 'area' | 'bar' | 'line';
  color: string;
  trend: 'up' | 'down' | 'neutral';
  changePercentage: number;
}

export interface MetricGroup {
  id: string;
  title: string;
  metrics: AdminMetric[];
}

export interface DashboardMetrics {
  totalCustomers: number;
  activeMembers: number;
  customers: any[];
}
