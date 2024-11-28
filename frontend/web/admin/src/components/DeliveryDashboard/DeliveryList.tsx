import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table from '../Table';
import styles from '../style/DeliveryList.module.css';

interface Delivery {
  id: string;
  taskId: string;
  deliveryDate: string;
  status: string;
}

const DeliveryList: React.FC = () => {
  const [deliveries, setDeliveries] = useState<Delivery[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchDeliveries = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/delivery');
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
    { key: 'taskId', label: 'Task ID' },
    { key: 'deliveryDate', label: 'Delivery Date' },
    { key: 'status', label: 'Status' },
  ];

  return (
    <div className={styles.deliveryListContainer}>
      <h2>Delivery List</h2>
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

export default DeliveryList;
