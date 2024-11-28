import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table from '../Table';
import styles from '../style/ServiceReports.module.css';

interface ServiceReport {
  id: string;
  name: string;
  date: string;
}

const ServiceReports: React.FC = () => {
  const [serviceReports, setServiceReports] = useState<ServiceReport[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchServiceReports = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/service-reports');
        setServiceReports(response.data);
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
    fetchServiceReports();
  }, []);

  const columns = [
    { key: 'id', label: 'Report ID' },
    { key: 'name', label: 'Name' },
    { key: 'date', label: 'Date' },
  ];

  return (
    <div className={styles.serviceReportsContainer}>
      <h2>Service Reports</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <Table data={serviceReports} columns={columns} />
      )}
    </div>
  );
};

export default ServiceReports;
