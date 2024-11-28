import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table from '../Table';
import styles from './style/ReportsView.module.css';

interface Report {
  id: string;
  name: string;
  date: string;
}

const ReportsView: React.FC = () => {
  const [reports, setReports] = useState<Report[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchReports = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/reports');
        setReports(response.data);
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
    fetchReports();
  }, []);

  const columns = [
    { key: 'id', label: 'Report ID' },
    { key: 'name', label: 'Name' },
    { key: 'date', label: 'Date' },
  ];

  return (
    <div className={styles.reportsViewContainer}>
      <h2>Reports View</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <Table data={reports} columns={columns} />
      )}
    </div>
  );
};

export default ReportsView;
