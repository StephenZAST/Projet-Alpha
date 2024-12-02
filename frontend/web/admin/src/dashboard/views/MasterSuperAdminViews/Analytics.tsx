import React, { useState } from 'react';
import { Chart } from '../../components/common/Chart/Chart';
import { StatCard } from '../../components/common/StatCard/StatCard';
import styles from './Analytics.module.css';

interface AnalyticsData {
  dailyActiveUsers: number[];
  revenue: number[];
  orderCompletion: number;
  customerSatisfaction: number;
  systemUptime: number;
  averageResponseTime: number;
}

export const Analytics: React.FC = () => {
  const [timeRange, setTimeRange] = useState('7d');
  const [selectedMetric, setSelectedMetric] = useState('users');

  // Mock data - In production, this would come from an API
  const analyticsData: AnalyticsData = {
    dailyActiveUsers: [1200, 1350, 1500, 1450, 1600, 1750, 1800],
    revenue: [15000, 16500, 17000, 16800, 18000, 19500, 20000],
    orderCompletion: 94.5,
    customerSatisfaction: 4.8,
    systemUptime: 99.99,
    averageResponseTime: 0.8,
  };

  const mockChartData = {
    users: [
      { name: 'Mon', value: 1200 },
      { name: 'Tue', value: 1350 },
      { name: 'Wed', value: 1500 },
      { name: 'Thu', value: 1450 },
      { name: 'Fri', value: 1600 },
      { name: 'Sat', value: 1750 },
      { name: 'Sun', value: 1800 },
    ],
    revenue: [
      { name: 'Mon', value: 15000 },
      { name: 'Tue', value: 16500 },
      { name: 'Wed', value: 17000 },
      { name: 'Thu', value: 16800 },
      { name: 'Fri', value: 18000 },
      { name: 'Sat', value: 19500 },
      { name: 'Sun', value: 20000 },
    ],
  };

  const stats = [
    {
      title: "Daily Active Users",
      value: analyticsData.dailyActiveUsers[6].toString(),
      icon: "/icons/users.svg",
      trend: {
        value: "12%",
        direction: "up",
        text: "vs last week"
      }
    },
    {
      title: "Revenue",
      value: `$${analyticsData.revenue[6].toLocaleString()}`,
      icon: "/icons/revenue.svg",
      trend: {
        value: "8%",
        direction: "up",
        text: "vs last week"
      }
    },
    {
      title: "Order Completion",
      value: `${analyticsData.orderCompletion}%`,
      icon: "/icons/orders.svg",
      trend: {
        value: "2.5%",
        direction: "up",
        text: "vs last month"
      }
    },
    {
      title: "Customer Satisfaction",
      value: analyticsData.customerSatisfaction.toString(),
      icon: "/icons/satisfaction.svg",
      trend: {
        value: "0.3",
        direction: "up",
        text: "vs last month"
      }
    }
  ];

  const performanceStats = [
    {
      title: "System Uptime",
      value: `${analyticsData.systemUptime}%`,
      icon: "/icons/uptime.svg",
    },
    {
      title: "Avg Response Time",
      value: `${analyticsData.averageResponseTime}s`,
      icon: "/icons/response-time.svg",
      trend: {
        value: "0.1s",
        direction: "down",
        text: "vs last week"
      }
    }
  ];

  return (
    <div className={styles.analytics}>
      <div className={styles.header}>
        <div className={styles.titleSection}>
          <h1 className={styles.title}>Analytics Dashboard</h1>
          <p className={styles.subtitle}>Track your system's performance and user engagement</p>
        </div>
        <div className={styles.timeRange}>
          <button
            className={`${styles.timeButton} ${timeRange === '24h' ? styles.active : ''}`}
            onClick={() => setTimeRange('24h')}
          >
            24h
          </button>
          <button
            className={`${styles.timeButton} ${timeRange === '7d' ? styles.active : ''}`}
            onClick={() => setTimeRange('7d')}
          >
            7d
          </button>
          <button
            className={`${styles.timeButton} ${timeRange === '30d' ? styles.active : ''}`}
            onClick={() => setTimeRange('30d')}
          >
            30d
          </button>
          <button
            className={`${styles.timeButton} ${timeRange === '90d' ? styles.active : ''}`}
            onClick={() => setTimeRange('90d')}
          >
            90d
          </button>
        </div>
      </div>

      <div className={styles.statsGrid}>
        {stats.map((stat, index) => (
          <StatCard
            key={index}
            title={stat.title}
            value={stat.value}
            icon={stat.icon}
            trend={{
              value: stat.trend.value,
              direction: stat.trend.direction as "up" | "down",
              text: stat.trend.text
            }}
          />
        ))}
      </div>

      <div className={styles.mainCharts}>
        <div className={styles.chartCard}>
          <div className={styles.chartHeader}>
            <div className={styles.chartTitle}>
              <h2>Trends Overview</h2>
              <p className={styles.chartSubtitle}>Track key metrics over time</p>
            </div>
            <div className={styles.chartControls}>
              <button
                className={`${styles.metricButton} ${selectedMetric === 'users' ? styles.active : ''}`}
                onClick={() => setSelectedMetric('users')}
              >
                Users
              </button>
              <button
                className={`${styles.metricButton} ${selectedMetric === 'revenue' ? styles.active : ''}`}
                onClick={() => setSelectedMetric('revenue')}
              >
                Revenue
              </button>
            </div>
          </div>
          <Chart
            data={mockChartData[selectedMetric as keyof typeof mockChartData]}
            height={400}
            dataKey="value"
          />
        </div>
      </div>

      <div className={styles.bottomSection}>
        <div className={styles.performanceSection}>
          <h2 className={styles.sectionTitle}>System Performance</h2>
          <div className={styles.performanceStats}>
            {performanceStats.map((stat, index) => (
              <StatCard
                key={index}
                title={stat.title}
                value={stat.value}
                icon={stat.icon}
                trend={{
                  value: stat.trend?.value || '',
                  direction: (stat.trend?.direction as 'up' | 'down') || 'up',
                  text: stat.trend?.text
                }}
              />
            ))}
          </div>
        </div>

        <div className={styles.insightsSection}>
          <h2 className={styles.sectionTitle}>Key Insights</h2>
          <div className={styles.insightsList}>
            <div className={styles.insightCard}>
              <div className={styles.insightIcon}>
                <span className="material-icons">trending_up</span>
              </div>
              <div className={styles.insightContent}>
                <h3>User Growth</h3>
                <p>20% increase in new user registrations this week</p>
              </div>
            </div>
            <div className={styles.insightCard}>
              <div className={styles.insightIcon}>
                <span className="material-icons">schedule</span>
              </div>
              <div className={styles.insightContent}>
                <h3>Peak Hours</h3>
                <p>Highest activity between 2 PM and 5 PM</p>
              </div>
            </div>
            <div className={styles.insightCard}>
              <div className={styles.insightIcon}>
                <span className="material-icons">warning</span>
              </div>
              <div className={styles.insightContent}>
                <h3>Attention Needed</h3>
                <p>Response time increased by 0.2s in mobile app</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
