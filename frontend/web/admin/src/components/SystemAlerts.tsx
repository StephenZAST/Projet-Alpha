import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table from './Table';
import styles from './style/SystemAlerts.module.css';

interface SystemAlert {
  id: string;
  message: string;
  timestamp: string;
}

const SystemAlerts = () => {
  const [systemAlerts, setSystemAlerts] = useState<SystemAlert[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchSystemAlerts = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/system-alerts');
        setSystemAlerts(response.data);
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
    fetchSystemAlerts();
  }, []);

  const columns = [
    { key: 'id', label: 'Alert ID' },
    { key: 'message', label: 'Message' },
    { key: 'timestamp', label: 'Timestamp' },
  ];

  return (
    <div className={styles.systemAlertsContainer}>
      <h2>System Alerts</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <Table data={systemAlerts} columns={columns} />
      )}
    </div>
  );
};

export { SystemAlerts };
