import React, { useState } from 'react';
import styles from './Overview.module.css';

interface AdminStats {
  totalAdmins: number;
  activeAdmins: number;
  pendingApprovals: number;
  recentActivities: number;
}

interface Activity {
  id: string;
  adminName: string;
  action: string;
  target: string;
  timestamp: string;
  status: 'completed' | 'pending' | 'failed';
}

interface Alert {
  id: string;
  type: 'warning' | 'info' | 'error';
  message: string;
  timestamp: string;
}

const SuperAdminOverview: React.FC = () => {
  // Mock data
  const stats: AdminStats = {
    totalAdmins: 45,
    activeAdmins: 38,
    pendingApprovals: 3,
    recentActivities: 128
  };

  const activities: Activity[] = [
    {
      id: '1',
      adminName: 'Sarah Johnson',
      action: 'User Permission Update',
      target: 'Marketing Team',
      timestamp: '2024-01-15T14:30:00',
      status: 'completed'
    },
    {
      id: '2',
      adminName: 'Michael Chen',
      action: 'Content Approval',
      target: 'Product Launch Post',
      timestamp: '2024-01-15T14:25:00',
      status: 'pending'
    },
    {
      id: '3',
      adminName: 'Emma Davis',
      action: 'User Account Creation',
      target: 'New Regional Manager',
      timestamp: '2024-01-15T14:20:00',
      status: 'completed'
    },
    {
      id: '4',
      adminName: 'Alex Thompson',
      action: 'Role Assignment',
      target: 'Support Team Lead',
      timestamp: '2024-01-15T14:15:00',
      status: 'failed'
    }
  ];

  const alerts: Alert[] = [
    {
      id: '1',
      type: 'warning',
      message: '3 admin accounts require approval',
      timestamp: '2024-01-15T14:30:00'
    },
    {
      id: '2',
      type: 'info',
      message: 'System maintenance scheduled for tonight',
      timestamp: '2024-01-15T14:25:00'
    },
    {
      id: '3',
      type: 'error',
      message: 'Failed login attempts detected',
      timestamp: '2024-01-15T14:20:00'
    }
  ];

  const [selectedTimeRange, setSelectedTimeRange] = useState('today');

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed':
        return styles.statusCompleted;
      case 'pending':
        return styles.statusPending;
      case 'failed':
        return styles.statusFailed;
      default:
        return '';
    }
  };

  const getAlertIcon = (type: string) => {
    switch (type) {
      case 'warning':
        return 'warning';
      case 'info':
        return 'info';
      case 'error':
        return 'error';
      default:
        return 'info';
    }
  };

  return (
    <div className={styles.overview}>
      <div className={styles.header}>
        <div className={styles.titleSection}>
          <h1 className={styles.title}>SuperAdmin Overview</h1>
          <p className={styles.subtitle}>Monitor and manage administrative activities</p>
        </div>
        <div className={styles.timeRange}>
          <button 
            className={`${styles.timeButton} ${selectedTimeRange === 'today' ? styles.active : ''}`}
            onClick={() => setSelectedTimeRange('today')}
          >
            Today
          </button>
          <button 
            className={`${styles.timeButton} ${selectedTimeRange === 'week' ? styles.active : ''}`}
            onClick={() => setSelectedTimeRange('week')}
          >
            This Week
          </button>
          <button 
            className={`${styles.timeButton} ${selectedTimeRange === 'month' ? styles.active : ''}`}
            onClick={() => setSelectedTimeRange('month')}
          >
            This Month
          </button>
        </div>
      </div>

      <div className={styles.statsGrid}>
        <div className={styles.statCard}>
          <span className="material-icons">group</span>
          <div className={styles.statInfo}>
            <h3>Total Admins</h3>
            <p>{stats.totalAdmins}</p>
          </div>
        </div>
        <div className={styles.statCard}>
          <span className="material-icons">check_circle</span>
          <div className={styles.statInfo}>
            <h3>Active Admins</h3>
            <p>{stats.activeAdmins}</p>
          </div>
        </div>
        <div className={styles.statCard}>
          <span className="material-icons">pending</span>
          <div className={styles.statInfo}>
            <h3>Pending Approvals</h3>
            <p>{stats.pendingApprovals}</p>
          </div>
        </div>
        <div className={styles.statCard}>
          <span className="material-icons">history</span>
          <div className={styles.statInfo}>
            <h3>Recent Activities</h3>
            <p>{stats.recentActivities}</p>
          </div>
        </div>
      </div>

      <div className={styles.mainContent}>
        <div className={styles.activitiesSection}>
          <div className={styles.sectionHeader}>
            <h2>Recent Activities</h2>
            <button className={styles.viewAllButton}>
              View All
              <span className="material-icons">chevron_right</span>
            </button>
          </div>
          <div className={styles.activityList}>
            {activities.map((activity) => (
              <div key={activity.id} className={styles.activityItem}>
                <div className={styles.activityIcon}>
                  <span className="material-icons">person</span>
                </div>
                <div className={styles.activityContent}>
                  <div className={styles.activityHeader}>
                    <span className={styles.adminName}>{activity.adminName}</span>
                    <span className={`${styles.activityStatus} ${getStatusColor(activity.status)}`}>
                      {activity.status}
                    </span>
                  </div>
                  <p className={styles.activityAction}>
                    {activity.action} - {activity.target}
                  </p>
                  <span className={styles.activityTime}>
                    {new Date(activity.timestamp).toLocaleTimeString()}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className={styles.alertsSection}>
          <div className={styles.sectionHeader}>
            <h2>Active Alerts</h2>
            <button className={styles.viewAllButton}>
              View All
              <span className="material-icons">chevron_right</span>
            </button>
          </div>
          <div className={styles.alertList}>
            {alerts.map((alert) => (
              <div key={alert.id} className={`${styles.alertItem} ${styles[alert.type]}`}>
                <span className="material-icons">{getAlertIcon(alert.type)}</span>
                <div className={styles.alertContent}>
                  <p>{alert.message}</p>
                  <span className={styles.alertTime}>
                    {new Date(alert.timestamp).toLocaleTimeString()}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default SuperAdminOverview;
