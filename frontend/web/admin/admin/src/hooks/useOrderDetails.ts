import { useState, useEffect, useCallback } from 'react';
import api from '../utils/api';
import { ENDPOINTS } from '../config/endpoints';
import { Order, OrderStatus } from '../types/order';

export const useOrderDetails = (orderId: string) => {
  const [order, setOrder] = useState<Order | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchOrderDetails = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await api.get<Order>(ENDPOINTS.ORDERS.DETAILS(orderId));
      setOrder(data);
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Failed to fetch order details');
    } finally {
      setLoading(false);
    }
  }, [orderId]);

  const updateOrderStatus = async (status: OrderStatus) => {
    try {
      await api.put(ENDPOINTS.ORDERS.UPDATE_STATUS(orderId), { status });
      await fetchOrderDetails();
    } catch (err: unknown) {
      throw new Error(err instanceof Error ? err.message : 'Failed to update order status');
    }
  };

  useEffect(() => {
    fetchOrderDetails();
  }, [orderId, fetchOrderDetails]);

  return { 
    order, 
    loading, 
    error, 
    updateOrderStatus,
    refetch: fetchOrderDetails 
  };
};
