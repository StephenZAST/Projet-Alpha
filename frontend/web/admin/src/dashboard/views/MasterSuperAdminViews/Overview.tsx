import React from 'react';
import { StatCard } from '../../components/common/StatCard/StatCard';
import { Chart } from '../../components/common/Chart/Chart';
import { TransferList } from '../../components/common/TransferList/TransferList';
import { mockStats, mockChartData, mockTransfers, mockMasterAdminData } from '../../services/mockData';
import styles from './Overview.module.css';

const Overview: React.FC = () => {
  return (
    <div className={styles.overview}>
      <div className={styles.header}>
        <h1 className={styles.title}>Dashboard Overview</h1>
        <div className={styles.period}>
          <button className={styles.periodButton}>
            <span className="material-icons">calendar_today</span>
            Last 30 days
            <span className="material-icons">arrow_drop_down</span>
          </button>
        </div>
      </div>

      <div className={styles.statsGrid}>
        {mockStats.map((stat, index) => (
          <StatCard
            key={index}
            title={stat.title}
            value={stat.value}
            icon={stat.icon}
            trend={stat.trend}
          />
        ))}
      </div>

      <div className={styles.chartsSection}>
        <div className={styles.mainChart}>
          <Chart
            title="Revenue Overview"
            data={mockChartData}
            dataKey="value"
            height={300}
          />
        </div>
        <div className={styles.sideStats}>
          <TransferList
            transfers={mockTransfers}
            title="Recent Transactions"
          />
        </div>
      </div>

      <div className={styles.recentActivity}>
        <h2 className={styles.sectionTitle}>Recent Activities</h2>
        <div className={styles.activityList}>
          {mockMasterAdminData.overview.recentActivities.map((activity) => (
            <div key={activity.id} className={styles.activityItem}>
              <div className={styles.activityIcon}>
                <span className="material-icons">notification_important</span>
              </div>
              <div className={styles.activityContent}>
                <p className={styles.activityText}>
                  <span className={styles.activityUser}>{activity.user}</span>
                  {activity.action}
                </p>
                <span className={styles.activityTime}>
                  {new Date(activity.timestamp).toLocaleTimeString()}
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Overview;