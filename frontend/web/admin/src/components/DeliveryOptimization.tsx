import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table from './Table';
import styles from './style/DeliveryOptimization.module.css';

interface DeliveryOptimization {
  id: string;
  route: string;
  schedule: string;
}

const DeliveryOptimization: React.FC = () => {
  const [deliveryOptimizations, setDeliveryOptimizations] = useState<DeliveryOptimization[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchDeliveryOptimizations = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/delivery-optimizations');
        setDeliveryOptimizations(response.data);
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
    fetchDeliveryOptimizations();
  }, []);

  const columns = [
    { key: 'id', label: 'ID' },
    { key: 'route', label: 'Route' },
    { key: 'schedule', label: 'Schedule' },
  ];

  return (
    <div className={styles.deliveryOptimizationContainer}>
      <h2>Delivery Optimization</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <Table data={deliveryOptimizations} columns={columns} />
      )}
    </div>
  );
};

export default DeliveryOptimization;
