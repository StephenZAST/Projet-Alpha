import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table from '../Table';
import styles from '../style/AdminActivityLog.module.css';

interface ActivityLogItem {
  timestamp: string;
  adminName: string;
  action: string;
  details?: string;
}

const AdminActivityLog: React.FC = () => {
  const [activityLogData, setActivityLogData] = useState<ActivityLogItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchActivityLogData = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/admin-activity-log');
        setActivityLogData(response.data);
      } catch (error) {
        if (error instanceof Error) {
          setError(error);
        } else {
          setError(new Error('Unknown error'));
        }
      } finally {
        setLoading(false);
      }
    };
    fetchActivityLogData();
  }, []);

  const columns = [
    { key: 'timestamp', label: 'Timestamp' },
    { key: 'adminName', label: 'Admin' },
    { key: 'action', label: 'Action' },
    { key: 'details', label: 'Details' },
  ];

  return (
    <div className={styles.adminActivityLogContainer}>
      <h2>Admin Activity Log</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <Table data={activityLogData} columns={columns} />
      )}
    </div>
  );
};

export default AdminActivityLog;
