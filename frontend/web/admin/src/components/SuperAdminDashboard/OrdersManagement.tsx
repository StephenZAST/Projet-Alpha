import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table from '../Table';
import styles from '../style/OrdersManagement.module.css';

interface Order {
  id: string;
  customerName: string;
  orderStatus: string;
}

const OrdersManagement: React.FC = () => {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchOrders = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/orders');
        setOrders(response.data);
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
    fetchOrders();
  }, []);

  const columns = [
    { key: 'id', label: 'Order ID' },
    { key: 'customerName', label: 'Customer Name' },
    { key: 'orderStatus', label: 'Order Status' },
  ];

  return (
    <div className={styles.ordersManagementContainer}>
      <h2>Orders Management</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <Table data={orders} columns={columns} />
      )}
    </div>
  );
};

export default OrdersManagement;