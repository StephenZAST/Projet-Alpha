import { useNavigate } from 'react-router-dom';
import { useOrders } from '../../hooks/useOrders';
import { Button } from '../../components/common/Button';
import { colors } from '../../theme/colors';
import { DataTable } from '../../components/common/DataTable';
import { OrderStatus } from '../../types/order';
import type { Order } from '../../types/order'; // Changed to type import

const getStatusColor = (status: OrderStatus) => {
  const statusColors = {
    'PENDING': colors.warning,
    'PROCESSING': colors.primaryLight,
    'COMPLETED': colors.success,
    'CANCELLED': colors.error,
    'DELIVERING': colors.warning,
    'DELIVERED': colors.success
  };
  return statusColors[status] || colors.gray500;
};

export const OrdersList = () => {
  const navigate = useNavigate();
  const { orders, loading, error, updateOrderStatus } = useOrders();

  const columns = [
    { key: 'id', label: 'Order ID' },
    { key: 'customerName', label: 'Customer' },
    { 
      key: 'amount', 
      label: 'Amount',
      render: (value: number) => `$${value.toFixed(2)}`
    },
    { 
      key: 'status', 
      label: 'Status',
      render: (_: unknown, order: Order) => (
        <select
          value={order.status}
          onChange={(e) => updateOrderStatus(order.id, e.target.value as OrderStatus)}
          style={{
            padding: '4px 8px',
            borderRadius: '4px',
            border: `1px solid ${colors.gray300}`,
            color: getStatusColor(order.status)
          }}
        >
          {['PENDING', 'PROCESSING', 'COMPLETED', 'CANCELLED', 'DELIVERING', 'DELIVERED'].map(status => (
            <option key={status} value={status}>{status}</option>
          ))}
        </select>
      )
    },
    { 
      key: 'createdAt', 
      label: 'Date',
      render: (value: string) => new Date(value).toLocaleDateString()
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (_: unknown, order: Order) => (
        <Button 
          variant="secondary"
          onClick={() => navigate(`/orders/${order.id}`)}
        >
          View Details
        </Button>
      )
    }
  ];

  if (loading) return <div>Loading orders...</div>;
  if (error) return <div style={{ color: colors.error }}>{error}</div>;

  return (
    <div style={{ padding: '24px' }}>
      <h1 style={{ marginBottom: '24px' }}>Orders Management</h1>
      <DataTable<Order>
        data={orders}
        columns={columns}
        loading={loading}
      />
    </div>
  );
};