import { useAdmin } from '../../hooks/useAdmin';
import { StatCard } from '../../components/dashboard/StatCard';
import { OrdersTable } from '../../components/dashboard/OrdersTable';
import { colors } from '../../theme/colors';

export const AdminDashboard = () => {
  const { stats, orders, loading, error, refetchStats } = useAdmin();

  if (loading) {
    return <div style={{ padding: '24px' }}>Loading dashboard data...</div>;
  }

  if (error) {
    return (
      <div style={{ 
        padding: '24px', 
        color: colors.error,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: '16px'
      }}>
        <p>Error loading dashboard: {error}</p>
        <button onClick={refetchStats}>Retry</button>
      </div>
    );
  }

  return (
    <div style={{ padding: '24px' }}>
      <h1 style={{ marginBottom: '24px' }}>Dashboard Overview</h1>
      
      <div style={{ 
        display: 'grid', 
        gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))',
        gap: '24px',
        marginBottom: '24px'
      }}>
        <StatCard 
          title="Total Orders" 
          value={stats?.orders || 0}
          change={10} // You might want to calculate this
        />
        <StatCard 
          title="Revenue" 
          value={`$${stats?.revenue?.toLocaleString() || 0}`}
          change={5}
        />
        <StatCard 
          title="Users" 
          value={stats?.users || 0}
          change={15}
        />
        <StatCard 
          title="Affiliates" 
          value={stats?.affiliates || 0}
          change={8}
        />
      </div>

      <OrdersTable orders={orders} />
    </div>
  );
};