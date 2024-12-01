import React, { useState } from 'react';
import styles from './Reports.module.css';

interface MetricCard {
  title: string;
  value: string;
  change: number;
  icon: string;
}

interface ChartData {
  labels: string[];
  values: number[];
}

interface TopItem {
  id: string;
  name: string;
  value: number;
  change: number;
}

export const Reports: React.FC = () => {
  const [selectedTimeRange, setSelectedTimeRange] = useState('7d');
  const [selectedMetric, setSelectedMetric] = useState('users');

  // Mock data
  const metrics: MetricCard[] = [
    {
      title: 'Total Users',
      value: '15,234',
      change: 12.5,
      icon: 'group'
    },
    {
      title: 'Active Content',
      value: '1,432',
      change: 8.3,
      icon: 'article'
    },
    {
      title: 'Engagement Rate',
      value: '64.8%',
      change: -2.4,
      icon: 'trending_up'
    },
    {
      title: 'Response Time',
      value: '1.2s',
      change: 15.7,
      icon: 'timer'
    }
  ];

  const usageData: ChartData = {
    labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    values: [1250, 1420, 1350, 1650, 1480, 1200, 1580]
  };

  const topContent: TopItem[] = [
    { id: '1', name: 'Product Launch Guide', value: 2456, change: 12.5 },
    { id: '2', name: 'Getting Started Tutorial', value: 2100, change: 8.3 },
    { id: '3', name: 'API Documentation', value: 1890, change: -2.4 },
    { id: '4', name: 'Best Practices', value: 1654, change: 15.7 },
    { id: '5', name: 'Release Notes', value: 1432, change: 5.2 }
  ];

  const topUsers: TopItem[] = [
    { id: '1', name: 'John Smith', value: 156, change: 12.5 },
    { id: '2', name: 'Emma Wilson', value: 142, change: 8.3 },
    { id: '3', name: 'Michael Brown', value: 128, change: -2.4 },
    { id: '4', name: 'Sarah Davis', value: 115, change: 15.7 },
    { id: '5', name: 'James Johnson', value: 98, change: 5.2 }
  ];

  return (
    <div className={styles.reports}>
      <div className={styles.header}>
        <div className={styles.titleSection}>
          <h1 className={styles.title}>Reports & Analytics</h1>
          <p className={styles.subtitle}>Track performance metrics and user engagement</p>
        </div>
        <div className={styles.timeRange}>
          <button 
            className={`${styles.timeButton} ${selectedTimeRange === '24h' ? styles.active : ''}`}
            onClick={() => setSelectedTimeRange('24h')}
          >
            24h
          </button>
          <button 
            className={`${styles.timeButton} ${selectedTimeRange === '7d' ? styles.active : ''}`}
            onClick={() => setSelectedTimeRange('7d')}
          >
            7d
          </button>
          <button 
            className={`${styles.timeButton} ${selectedTimeRange === '30d' ? styles.active : ''}`}
            onClick={() => setSelectedTimeRange('30d')}
          >
            30d
          </button>
          <button 
            className={`${styles.timeButton} ${selectedTimeRange === '90d' ? styles.active : ''}`}
            onClick={() => setSelectedTimeRange('90d')}
          >
            90d
          </button>
        </div>
      </div>

      <div className={styles.metricsGrid}>
        {metrics.map((metric, index) => (
          <div key={index} className={styles.metricCard}>
            <div className={styles.metricIcon}>
              <span className="material-icons">{metric.icon}</span>
            </div>
            <div className={styles.metricInfo}>
              <h3>{metric.title}</h3>
              <div className={styles.metricValue}>
                <span className={styles.value}>{metric.value}</span>
                <span className={`${styles.change} ${metric.change >= 0 ? styles.positive : styles.negative}`}>
                  <span className="material-icons">
                    {metric.change >= 0 ? 'arrow_upward' : 'arrow_downward'}
                  </span>
                  {Math.abs(metric.change)}%
                </span>
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className={styles.mainCharts}>
        <div className={styles.chartCard}>
          <div className={styles.chartHeader}>
            <div className={styles.chartTitle}>
              <h2>Usage Analytics</h2>
              <p>Track user activity and engagement</p>
            </div>
            <div className={styles.chartControls}>
              <button 
                className={`${styles.metricButton} ${selectedMetric === 'users' ? styles.active : ''}`}
                onClick={() => setSelectedMetric('users')}
              >
                Users
              </button>
              <button 
                className={`${styles.metricButton} ${selectedMetric === 'sessions' ? styles.active : ''}`}
                onClick={() => setSelectedMetric('sessions')}
              >
                Sessions
              </button>
              <button 
                className={`${styles.metricButton} ${selectedMetric === 'actions' ? styles.active : ''}`}
                onClick={() => setSelectedMetric('actions')}
              >
                Actions
              </button>
            </div>
          </div>
          <div className={styles.chartContent}>
            {/* Chart visualization would go here */}
            <div className={styles.mockChart}>
              {usageData.values.map((value, index) => (
                <div 
                  key={index} 
                  className={styles.chartBar}
                  style={{ height: `${(value / Math.max(...usageData.values)) * 100}%` }}
                >
                  <span className={styles.barValue}>{value}</span>
                  <span className={styles.barLabel}>{usageData.labels[index]}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      <div className={styles.insightsGrid}>
        <div className={styles.insightCard}>
          <div className={styles.insightHeader}>
            <h2>Top Content</h2>
            <button className={styles.viewAllButton}>
              View All
              <span className="material-icons">chevron_right</span>
            </button>
          </div>
          <div className={styles.insightList}>
            {topContent.map((item, index) => (
              <div key={item.id} className={styles.insightItem}>
                <div className={styles.insightRank}>{index + 1}</div>
                <div className={styles.insightInfo}>
                  <span className={styles.insightName}>{item.name}</span>
                  <div className={styles.insightStats}>
                    <span className={styles.insightValue}>{item.value} views</span>
                    <span className={`${styles.insightChange} ${item.change >= 0 ? styles.positive : styles.negative}`}>
                      <span className="material-icons">
                        {item.change >= 0 ? 'arrow_upward' : 'arrow_downward'}
                      </span>
                      {Math.abs(item.change)}%
                    </span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className={styles.insightCard}>
          <div className={styles.insightHeader}>
            <h2>Top Users</h2>
            <button className={styles.viewAllButton}>
              View All
              <span className="material-icons">chevron_right</span>
            </button>
          </div>
          <div className={styles.insightList}>
            {topUsers.map((item, index) => (
              <div key={item.id} className={styles.insightItem}>
                <div className={styles.insightRank}>{index + 1}</div>
                <div className={styles.insightInfo}>
                  <span className={styles.insightName}>{item.name}</span>
                  <div className={styles.insightStats}>
                    <span className={styles.insightValue}>{item.value} actions</span>
                    <span className={`${styles.insightChange} ${item.change >= 0 ? styles.positive : styles.negative}`}>
                      <span className="material-icons">
                        {item.change >= 0 ? 'arrow_upward' : 'arrow_downward'}
                      </span>
                      {Math.abs(item.change)}%
                    </span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};
