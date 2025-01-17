
    try {
      await api.put(ENDPOINTS.ORDERS.UPDATE_STATUS(orderId), { status });
      await fetchOrders();
    } catch (err: any) {
      throw new Error(err.message || 'Failed to update order status');
    }
  };

  const getOrderDetails = async (orderId: string) => {
    try {
      setLoading(true);
      const data = await api.get<Order>(ENDPOINTS.ORDERS.DETAILS(orderId));
      setSelectedOrder(data);
      return data;
    } catch (err: any) {
      throw new Error(err.message || 'Failed to fetch order details');
    } finally {
      setLoading(false);
    }
  };

  return {
    orders,
    selectedOrder,
    loading,
    error,
    fetchOrders,
    updateOrderStatus,
    getOrderDetails
  };
};