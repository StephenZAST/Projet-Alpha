import React from 'react';
import { MasterSuperAdminDashboard } from './layouts/MasterSuperAdminDashboard';
import { SuperAdminDashboard } from './layouts/SuperAdminDashboard';
import { SecretaryDashboard } from './layouts/SecretaryDashboard';
import { DeliveryDashboard } from './layouts/DeliveryDashboard';
import { CustomerServiceDashboard } from './layouts/CustomerServiceDashboard';
import { SupervisorDashboard } from './layouts/SupervisorDashboard';

interface DashboardRouterProps {
  userRole: 'masterSuperAdmin' | 'superAdmin' | 'secretary' | 'delivery' | 'customerService' | 'supervisor';
}

export const DashboardRouter: React.FC<DashboardRouterProps> = ({ userRole }) => {
  switch (userRole) {
    case 'masterSuperAdmin':
      return <MasterSuperAdminDashboard />;
    case 'superAdmin':
      return <SuperAdminDashboard />;
    case 'secretary':
      return <SecretaryDashboard />;
    case 'delivery':
      return <DeliveryDashboard />;
    case 'customerService':
      return <CustomerServiceDashboard />;
    case 'supervisor':
      return <SupervisorDashboard />;
    default:
      return null;
  }
};