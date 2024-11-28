import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table from './Tablecontainer';
import styles from './style/FinancialReports.module.css';

interface FinancialReport {
  id: string;
  name: string;
  date: string;
}

const FinancialReports: React.FC = () => {
  const [financialReports, setFinancialReports] = useState<FinancialReport[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchFinancialReports = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/financial-reports');
        setFinancialReports(response.data);
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
    fetchFinancialReports();
  }, []);

  const columns = [
    { key: 'id', label: 'Report ID' },
    { key: 'name', label: 'Name' },
    { key: 'date', label: 'Date' },
  ];

  return (
    <div className={styles.financialReportsContainer}>
      <h2>Financial Reports</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <Table data={financialReports} columns={columns} />
      )}
    </div>
  );
};

export default FinancialReports;
