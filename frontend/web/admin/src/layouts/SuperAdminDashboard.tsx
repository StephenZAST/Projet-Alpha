import React, { useState } from 'react';
import { DashboardLayout } from './DashboardLayout';
import StaffManagement from '../components/StaffManagement'; // Corrected import
import OrdersManagement from '../components/OrdersManagement'; // Corrected import
import CustomerManagement from '../components/CustomerManagement'; // Corrected import
import ReportsView from '../components/ReportsView'; // Corrected import
import Settings from '../components/Settings'; // Corrected import
import styles from './style/SuperAdminDashboard.module.css';

export const SuperAdminDashboard: React.FC = () => {
  const [selectedView, setSelectedView] = useState('dashboard');

  const sidebarItems = [
    { icon: '/icons/dashboard.svg', label: 'Tableau de Bord', value: 'dashboard' },
    { icon: '/icons/staff.svg', label: 'Gestion du Personnel', value: 'staff' },
    { icon: '/icons/orders.svg', label: 'Gestion des Commandes', value: 'orders' },
    { icon: '/icons/customers.svg', label: 'Gestion Clients', value: 'customers' },
    { icon: '/icons/reports.svg', label: 'Rapports', value: 'reports' },
    { icon: '/icons/settings.svg', label: 'Paramètres', value: 'settings' }
  ];

  const renderContent = () => {
    switch(selectedView) {
      case 'staff':
        return <StaffManagement />;
      case 'orders':
        return <OrdersManagement />;
      case 'customers':
        return <CustomerManagement />;
      case 'reports':
        return <ReportsView />;
      case 'settings':
        return <Settings />;
      default:
        return (
          <div className={styles.dashboardOverview}>
            <h1>Vue d'ensemble</h1>
          </div>
        );
    }
  };

  return (
    <DashboardLayout
      sidebarItems={sidebarItems}
      selectedView={selectedView}
      onViewChange={setSelectedView}
      userRole="Super Admin"
    >
      <div className={styles.dashboardContent}>
        {renderContent()}
      </div>
    </DashboardLayout>
  );
};
