import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table from './Table';
import styles from './style/DeliveryReports.module.css';

interface DeliveryReport {
  id: string;
  deliveryDate: string;
  deliveryStatus: string;
}

const DeliveryReports: React.FC = () => {
  const [deliveryReports, setDeliveryReports] = useState<DeliveryReport[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchDeliveryReports = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/delivery-reports');
        setDeliveryReports(response.data);
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
    fetchDeliveryReports();
  }, []);

  const columns = [
    { key: 'id', label: 'Report ID' },
    { key: 'deliveryDate', label: 'Delivery Date' },
    { key: 'deliveryStatus', label: 'Delivery Status' },
  ];

  return (
    <div className={styles.deliveryReportsContainer}>
      <h2>Delivery Reports</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <Table data={deliveryReports} columns={columns} />
      )}
    </div>
  );
};

export default DeliveryReports;
