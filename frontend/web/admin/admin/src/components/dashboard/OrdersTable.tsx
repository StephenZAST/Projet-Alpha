import { colors } from '../../theme/colors';
import { Order } from '../../types/order';

const getStatusColor = (status: string) => {
  switch (status) {
    case 'PENDING': return colors.warning;
    case 'COMPLETED': return colors.success;
    case 'CANCELLED': return colors.error;
    default: return colors.gray500;
  }
};

export const OrdersTable: React.FC<{ orders: Order[] }> = ({ orders }) => {
  return (
    <div style={{ 
      backgroundColor: colors.white, 
      padding: '24px', 
      borderRadius: '12px',
      boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
    }}>
      <h2 style={{ marginBottom: '16px', color: colors.gray800 }}>Recent Orders</h2>
      <div style={{ overflowX: 'auto' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead>
            <tr>
              <th style={{ textAlign: 'left', padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>ID</th>
              <th style={{ textAlign: 'left', padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>Customer</th>
              <th style={{ textAlign: 'left', padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>Amount</th>
              <th style={{ textAlign: 'left', padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>Status</th>
              <th style={{ textAlign: 'left', padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>Date</th>
            </tr>
          </thead>
          <tbody>
            {orders.map(order => (
              <tr key={order.id}>
                <td style={{ padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>{order.id}</td>
                <td style={{ padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>{order.customer}</td>
                <td style={{ padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>${order.amount}</td>
                <td style={{ padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>
                  <span style={{ 
                    color: getStatusColor(order.status),
                    backgroundColor: `${getStatusColor(order.status)}20`,
                    padding: '4px 8px',
                    borderRadius: '4px',
                    fontSize: '14px'
                  }}>
                    {order.status}
                  </span>
                </td>
                <td style={{ padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>{order.date}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};