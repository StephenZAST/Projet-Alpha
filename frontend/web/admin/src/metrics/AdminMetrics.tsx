import React from 'react';
import { Card } from '../ui/Card';
import { MetricChart } from '../ui/MetricChart';
import { AdminMetric } from '../types/metrics';
import styles from './AdminMetrics.module.css';

interface AdminMetricsProps {
  metrics: AdminMetric[];
}

export const AdminMetrics: React.FC<AdminMetricsProps> = ({ metrics }) => {
  return (
    <div className={styles.metricsGrid}>
      {metrics.map((metric) => (
        <Card key={metric.id} className={styles.metricCard}>
          <div className={styles.metricHeader}>
            <h3 className={styles.metricTitle}>{metric.title}</h3>
            <span className={styles.metricValue}>{metric.value}</span>
          </div>
          <MetricChart 
            data={metric.chartData}
            type={metric.chartType}
            color={metric.color}
          />
          <div className={styles.metricFooter}>
            <span className={styles.metricChange} data-trend={metric.trend}>
              {metric.changePercentage}%
            </span>
            <span className={styles.metricPeriod}>vs last month</span>
          </div>
        </Card>
      ))}
    </div>
  );
};