import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table from '../Table';
import styles from '../style/ServiceStatistics.module.css';

interface ServiceStatistic {
  id: string;
  name: string;
  value: number;
}

const ServiceStatistics: React.FC = () => {
  const [serviceStatistics, setServiceStatistics] = useState<ServiceStatistic[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchServiceStatistics = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/service-statistics');
        setServiceStatistics(response.data);
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
    fetchServiceStatistics();
  }, []);

  const columns = [
    { key: 'id', label: 'Statistic ID' },
    { key: 'name', label: 'Name' },
    { key: 'value', label: 'Value' },
  ];

  return (
    <div className={styles.serviceStatisticsContainer}>
      <h2>Service Statistics</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <Table data={serviceStatistics} columns={columns} />
      )}
    </div>
  );
};

export default ServiceStatistics;
