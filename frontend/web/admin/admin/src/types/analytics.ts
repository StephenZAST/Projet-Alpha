export type TimeFrame = 'daily' | 'weekly' | 'monthly' | 'yearly';

export interface DataPoint {
  date: string;
  value: number;
}

export interface AnalyticsMetrics {
  timeframe: TimeFrame;
  data: {
    orders: number;
    revenue: number;
    affiliateSignups: number;
    conversionRate: number;
    date: string;
  }[];
}

export interface ReportConfig {
  type: 'orders' | 'revenue' | 'affiliates';
  timeframe: TimeFrame;
  format: 'csv' | 'pdf';
}

export interface ChartData {
  labels: string[];
  datasets: {
    label: string;
    data: number[];
    borderColor: string;
    fill: boolean;
  }[];
}
