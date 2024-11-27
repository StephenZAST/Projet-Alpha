import React from 'react';
import Table from './Table';
import styles from './style/AdminActivityLog.module.css';

interface ActivityLogItem {
  timestamp: string;
  adminName: string;
  action: string;
  details?: string;
}

const activityLogData: ActivityLogItem[] = [
  {
    timestamp: '2023-12-28T10:00:00Z',
    adminName: 'John Doe',
    action: 'Created a new user',
    details: 'User ID: 123',
  },
  // ... more activity log data
];

const AdminActivityLog: React.FC = () => {
  const columns = [
    { key: 'timestamp', label: 'Timestamp' },
    { key: 'adminName', label: 'Admin' },
    { key: 'action', label: 'Action' },
    { key: 'details', label: 'Details' },
  ];

  return (
    <div className={styles.adminActivityLogContainer}>
      <h2>Admin Activity Log</h2>
      <Table data={activityLogData} columns={columns} />
    </div>
  );
};

export default AdminActivityLog;
