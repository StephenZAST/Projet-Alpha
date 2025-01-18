import { useState, useCallback } from 'react';
import { api } from '../utils/api';
import { DeliveryOrder, DeliveryOrderStatus } from '../types/delivery';

export const useDelivery = () => {
  const [orders, setOrders] = useState<Record<DeliveryOrderStatus, DeliveryOrder[]>>({
    PENDING: [],
    COLLECTING: [],
    COLLECTED: [],
    PROCESSING: [],
    READY: [],
    DELIVERING: [],
    DELIVERED: [],
    CANCELLED: []
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchOrdersByStatus = useCallback(async (status: DeliveryOrderStatus) => {
    try {
      const response = await api.get<DeliveryOrder[]>(`/delivery/${status.toLowerCase()}-orders`);
      setOrders(prev => ({ ...prev, [status]: response }));
      return response;
    } catch (err: unknown) {
      const error = err instanceof Error ? err.message : `Failed to fetch ${status} orders`;
      throw new Error(error);
    }
  }, []);

  const updateOrderStatus = async (orderId: string, status: DeliveryOrderStatus) => {
    try {
      await api.patch(`/delivery/${orderId}/status`, { status });
      // Refetch orders for both old and new status
      await Promise.all(Object.keys(orders).map(status => 
        fetchOrdersByStatus(status as DeliveryOrderStatus)
      ));
    } catch (err: unknown) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to update order status';
      throw new Error(errorMessage);
    }
  };

  const fetchAllOrders = useCallback(async () => {
    setLoading(true);
    try {
      await Promise.all(Object.keys(orders).map(status => 
        fetchOrdersByStatus(status as DeliveryOrderStatus)
      ));
      setError(null);
    } catch (err: unknown) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to fetch orders';
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  }, [fetchOrdersByStatus, orders]);

  return {
    orders,
    loading,
    error,
    fetchAllOrders,
    fetchOrdersByStatus,
    updateOrderStatus
  };
};
