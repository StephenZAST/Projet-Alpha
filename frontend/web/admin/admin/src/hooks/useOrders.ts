import { useState, useCallback } from 'react';
import { api } from '../utils/api';

export const useOrders = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchOrders = useCallback(async () => {
    try {
      setLoading(true);
      const response = await api.get('/admin/orders');
      setOrders(response);
      setError(null);
    } catch (err: Error) {
      setError(err.message || 'Failed to fetch orders');
    } finally {
      setLoading(false);
    }
  }, []);

  const updateOrderStatus = async (orderId: string, status: string) => {
    try {
      await api.put(`/admin/orders/${orderId}/status`, { status });
      await fetchOrders();
    } catch (err: Error) {
      throw new Error(err.message || 'Failed to update order status');
    }
  };

  const getOrderDetails = async (orderId: string) => {
    try {
      const response = await api.get(`/admin/orders/${orderId}`);
      return response;
    } catch (err: Error) {
      throw new Error(err.message || 'Failed to fetch order details');
    }
  };

  return {
    orders,
    loading,
    error,
    fetchOrders,
    updateOrderStatus,
    getOrderDetails
  };
};