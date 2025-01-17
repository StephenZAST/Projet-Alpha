import { useNavigate } from 'react-router-dom';
import { useOrders } from '../../hooks/useOrders';
import { Button } from '../../components/common/Button';
import { colors } from '../../theme/colors';
import { Order, OrderStatus } from '../../types/order';

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

  if (loading) {
    return <div style={{ padding: '24px' }}>Loading orders...</div>;
  }

  if (error) {
    return (
      <div style={{ padding: '24px', color: colors.error }}>
        Error loading orders: {error}
      </div>
    );
  }

  return (
    <div style={{ padding: '24px' }}>
      <h1 style={{ marginBottom: '24px' }}>Orders Management</h1>
      <div style={{ 
        backgroundColor: colors.white, 
        padding: '24px', 
        borderRadius: '12px',
        boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
      }}>
        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead>
            <tr>
              <th style={{ textAlign: 'left', padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>Order ID</th>
              <th style={{ textAlign: 'left', padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>Customer</th>
              <th style={{ textAlign: 'left', padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>Amount</th>
              <th style={{ textAlign: 'left', padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>Status</th>
              <th style={{ textAlign: 'left', padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>Date</th>
              <th style={{ textAlign: 'right', padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {orders.map(order => (
              <tr key={order.id}>
                <td style={{ padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>{order.id}</td>
                <td style={{ padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>{order.customerName}</td>
                <td style={{ padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>${order.amount.toFixed(2)}</td>
                <td style={{ padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>
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
                </td>
                <td style={{ padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>
                  {new Date(order.createdAt).toLocaleDateString()}
                </td>
                <td style={{ padding: '12px', borderBottom: `1px solid ${colors.gray200}`, textAlign: 'right' }}>
                  <Button 
                    variant="secondary"
                    onClick={() => navigate(`/orders/${order.id}`)}
                  >
                    View Details
                  </Button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};