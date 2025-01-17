import { Navigate } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import { AdminDashboard } from './AdminDashboard';
import { DeliveryDashboard } from './DeliveryDashboard';
import { SuperAdminDashboard } from './SuperAdminDashboard';

export const DashboardRouter = () => {
  const { state } = useAuth();

  switch (state.user?.role) {
    case 'SUPER_ADMIN':
      return <SuperAdminDashboard />;
    case 'ADMIN':
      return <AdminDashboard />;
    case 'DELIVERY':
      return <DeliveryDashboard />;
    default:
      return <Navigate to="/unauthorized" />;
  }
};
