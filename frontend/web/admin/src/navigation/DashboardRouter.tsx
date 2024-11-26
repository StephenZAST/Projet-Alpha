import * as React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';
import { MasterSuperAdminDashboard } from '../layouts/MasterSuperAdminDashboard';
import { SuperAdminDashboard } from '../layouts/SuperAdminDashboard';
import { SecretaryDashboard } from '../layouts/SecretaryDashboard';
import { DeliveryDashboard } from '../layouts/DeliveryDashboard';
import { CustomerServiceDashboard } from '../layouts/CustomerServiceDashboard';
import { SupervisorDashboard } from '../layouts/SupervisorDashboard';

export function DashboardRouter() {
  const { user } = useAuth();

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  const dashboardMap = {
    master: MasterSuperAdminDashboard,
    super: SuperAdminDashboard,
    secretary: SecretaryDashboard,
    delivery: DeliveryDashboard,
    customer: CustomerServiceDashboard,
    supervisor: SupervisorDashboard,
  };

  const DashboardComponent = dashboardMap[user.type];

  return (
    <Routes>
      <Route path="/*" element={<DashboardComponent />} />
    </Routes>
  );
}