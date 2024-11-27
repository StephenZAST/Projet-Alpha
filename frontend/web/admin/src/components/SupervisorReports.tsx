import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table from './Table';
import styles from './style/SupervisorReports.module.css';

interface SupervisorReport {
  id: string;
  name: string;
  date: string;
}

const SupervisorReports: React.FC = () => {
  const [supervisorReports, setSupervisorReports] = useState<SupervisorReport[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchSupervisorReports = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/supervisor-reports');
        setSupervisorReports(response.data);
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
    fetchSupervisorReports();
  }, []);

  const columns = [
    { key: 'id', label: 'Report ID' },
    { key: 'name', label: 'Name' },
    { key: 'date', label: 'Date' },
  ];

  return (
    <div className={styles.supervisorReportsContainer}>
      <h2>Supervisor Reports</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <Table data={supervisorReports} columns={columns} />
      )}
    </div>
  );
};

export default SupervisorReports;
