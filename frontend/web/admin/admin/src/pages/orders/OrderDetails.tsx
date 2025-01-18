import { useParams } from 'react-router-dom';
import { useOrderDetails } from '../../hooks/useOrderDetails';
import { colors } from '../../theme/colors';
import { OrderStatus } from '../../types/order';

const STATUS_COLORS = {
  PENDING: colors.warning,
  PROCESSING: colors.primaryLight,
  COMPLETED: colors.success,
  CANCELLED: colors.error,
  DELIVERING: colors.warning,
  DELIVERED: colors.success
};

export const OrderDetails = () => {
  const { id } = useParams<{ id: string }>();
  const { order, loading, error, updateOrderStatus } = useOrderDetails(id!);

  if (loading) {
    return <div style={{ padding: '24px' }}>Loading order details...</div>;
  }

  if (error) {
    return (
      <div style={{ 
        padding: '24px', 
        color: colors.error 
      }}>
        {error}
      </div>
    );
  }

  if (!order) {
    return <div style={{ padding: '24px' }}>Order not found</div>;
  }

  return (
    <div style={{ padding: '24px' }}>
      <div style={{ 
        display: 'flex', 
        justifyContent: 'space-between', 
        alignItems: 'center',
        marginBottom: '24px' 
      }}>
        <h1>Order #{order.id.slice(0, 8)}</h1>
        <select
          value={order.status}
          onChange={(e) => updateOrderStatus(e.target.value as OrderStatus)}
          style={{
            padding: '8px 16px',
            borderRadius: '8px',
            border: `1px solid ${colors.gray300}`,
            color: STATUS_COLORS[order.status as keyof typeof STATUS_COLORS]
          }}
        >
          {Object.keys(STATUS_COLORS).map(status => (
            <option key={status} value={status}>{status}</option>
          ))}
        </select>
      </div>

      <div style={{ 
        display: 'grid', 
        gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', 
        gap: '24px',
        marginBottom: '24px' 
      }}>
        <InfoCard title="Order Information">
          <p>Created: {new Date(order.createdAt).toLocaleString()}</p>
          <p>Total Amount: ${order.amount.toFixed(2)}</p>
          <p>Payment Status: {order.paymentStatus}</p>
          <p>Payment Method: {order.paymentMethod}</p>
        </InfoCard>

        <InfoCard title="Customer Information">
          <p>Name: {order.customerName}</p>
          <p>Address: {order.address?.street}</p>
          <p>City: {order.address?.city}</p>
          <p>Postal Code: {order.address?.postal_code}</p>
        </InfoCard>
      </div>

      <InfoCard title="Order Items">
        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead>
            <tr>
              <th style={tableHeaderStyle}>Item</th>
              <th style={tableHeaderStyle}>Quantity</th>
              <th style={tableHeaderStyle}>Price</th>
              <th style={tableHeaderStyle}>Total</th>
            </tr>
          </thead>
          <tbody>
            {order.items.map(item => (
              <tr key={item.id}>
                <td style={tableCellStyle}>{item.productName}</td>
                <td style={tableCellStyle}>{item.quantity}</td>
                <td style={tableCellStyle}>${item.price.toFixed(2)}</td>
                <td style={tableCellStyle}>${(item.quantity * item.price).toFixed(2)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </InfoCard>
    </div>
  );
};

const InfoCard: React.FC<{ title: string; children: React.ReactNode }> = ({ title, children }) => (
  <div style={{ 
    backgroundColor: colors.white, 
    padding: '24px',
    borderRadius: '12px',
    boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
  }}>
    <h3 style={{ marginBottom: '16px', color: colors.gray800 }}>{title}</h3>
    {children}
  </div>
);

const tableHeaderStyle = {
  textAlign: 'left' as const,
  padding: '12px',
  borderBottom: `1px solid ${colors.gray200}`,
  color: colors.gray600
};

const tableCellStyle = {
  padding: '12px',
  borderBottom: `1px solid ${colors.gray200}`
};