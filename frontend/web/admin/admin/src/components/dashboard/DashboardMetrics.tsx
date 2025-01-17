import { UserRole } from '../../types/auth';
import { DashboardMetrics } from '../../types/dashboard';
import { StatCard } from '../common/StatCard';

interface DashboardMetricsProps {
  role: UserRole;
  metrics: DashboardMetrics;
}

export const DashboardMetrics: React.FC<DashboardMetricsProps> = ({ role, metrics }) => {
  const getMetricsForRole = () => {
    switch (role) {
      case 'SUPER_ADMIN':
        return [
          { title: 'Total Users', value: metrics.users || 0, change: 5 },
          { title: 'Total Revenue', value: `$${metrics.revenue?.toLocaleString() || 0}`, change: 12 },
          { title: 'Active Users', value: metrics.activeUsers || 0, change: 8 },
          { title: 'Active Affiliates', value: metrics.affiliates || 0, change: 15 }
        ];
      case 'ADMIN':
        return [
          { title: 'Daily Orders', value: metrics.dailyOrders || 0, change: 3 },
          { title: 'Monthly Revenue', value: `$${metrics.monthlyRevenue?.toLocaleString() || 0}`, change: 7 },
          { title: 'Active Affiliates', value: metrics.affiliates || 0, change: 4 }
        ];
      case 'DELIVERY':
        return [
          { title: 'Pending Deliveries', value: metrics.pendingDeliveries || 0 },
          { title: 'Completed Today', value: metrics.completedDeliveries || 0, change: 2 }
        ];
      default:
        return [];
    }
  };

  const metricsData = getMetricsForRole();

  return (
    <div style={{ 
      display: 'grid', 
      gridTemplateColumns: `repeat(auto-fit, minmax(240px, 1fr))`,
      gap: '24px',
      marginBottom: '24px'
    }}>
      {metricsData.map((metric, index) => (
        <StatCard key={index} {...metric} />
      ))}
    </div>
  );
};
