import React, { useState, useEffect } from 'react';
import { useDelivery } from '../../hooks/useDelivery';
import { DeliveryOrder, DeliveryOrderStatus } from '../../types/delivery';
import { DataTable } from '../../components/common/DataTable';
import { Button } from '../../components/common/Button';
import { LoadingSpinner } from '../../components/common/Loading';
import { colors } from '../../theme/colors';

// Add type for table column
interface Column {
  key: keyof DeliveryOrder | 'actions';
  label: string;
  render?: (value: unknown, item: DeliveryOrder) => React.ReactNode;
}

export const DeliveryDashboard = () => {
  const { orders, loading, error, fetchAllOrders, updateOrderStatus } = useDelivery();
  const [activeTab, setActiveTab] = useState<DeliveryOrderStatus>('PENDING');

  useEffect(() => {
    fetchAllOrders();
  }, [fetchAllOrders]);

  const getNextStatus = (currentStatus: DeliveryOrderStatus): DeliveryOrderStatus | null => {
    const statusFlow = {
      'PENDING': 'COLLECTING',
      'COLLECTING': 'COLLECTED',
      'COLLECTED': 'PROCESSING',
      'PROCESSING': 'READY',
      'READY': 'DELIVERING',
      'DELIVERING': 'DELIVERED'
    } as const;

    return statusFlow[currentStatus] || null;
  };

  const columns: Column[] = [
    { key: 'id', label: 'Order ID' },
    { key: 'customerName', label: 'Customer' },
    { 
      key: 'address', 
      label: 'Address',
      render: (value: DeliveryOrder['address']) => 
        value ? `${value.street}, ${value.city} ${value.postal_code}` : 'N/A'
    },
    { 
      key: 'totalAmount', 
      label: 'Amount',
      render: (value: number) => `$${value.toFixed(2)}`
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (_, order: DeliveryOrder) => {
        const nextStatus = getNextStatus(order.status);
        return nextStatus ? (
          <Button
            onClick={() => updateOrderStatus(order.id, nextStatus)}
            variant="primary"
          >
            Mark as {nextStatus.toLowerCase()}
          </Button>
        ) : null;
      }
    }
  ];

  if (loading) return <LoadingSpinner />;
  if (error) return <div style={{ color: colors.error }}>{error}</div>;

  return (
    <div style={{ padding: '24px' }}>
      <h1 style={{ marginBottom: '24px' }}>Delivery Dashboard</h1>

      <div style={{ 
        display: 'flex', 
        gap: '8px',
        marginBottom: '24px',
        overflowX: 'auto',
        padding: '8px 0'
      }}>
        {(Object.keys(orders) as DeliveryOrderStatus[]).map(status => (
          <Button
            key={status}
            variant={activeTab === status ? 'primary' : 'secondary'}
            onClick={() => setActiveTab(status)}
          >
            {status} ({orders[status].length})
          </Button>
        ))}
      </div>

      <DataTable<DeliveryOrder>
        data={orders[activeTab]}
        columns={columns}
        loading={loading}
      />
    </div>
  );
};