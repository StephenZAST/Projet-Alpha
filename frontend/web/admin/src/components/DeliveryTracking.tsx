import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table from './Tablecontainer';
import styles from './style/DeliveryTracking.module.css';

interface Delivery {
  id: string;
  customerName: string;
  deliveryAddress: string;
  deliveryStatus: string;
}

const DeliveryTracking: React.FC = () => {
  const [deliveries, setDeliveries] = useState<Delivery[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchDeliveries = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/deliveries');
        setDeliveries(response.data);
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
    fetchDeliveries();
  }, []);

  const columns = [
    { key: 'id', label: 'Delivery ID' },
    { key: 'customerName', label: 'Customer Name' },
    { key: 'deliveryAddress', label: 'Delivery Address' },
    { key: 'deliveryStatus', label: 'Delivery Status' },
  ];

  return (
    <div className={styles.deliveryTrackingContainer}>
      <h2>Delivery Tracking</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <Table data={deliveries} columns={columns} />
      )}
    </div>
  );
};

export default DeliveryTracking;
