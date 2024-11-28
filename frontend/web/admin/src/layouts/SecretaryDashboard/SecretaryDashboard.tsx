import React, { useState } from 'react';
import { DashboardLayout } from '../DashboardLayout/DashboardLayout';
import DailyOverview from '../../components/SecretaryDashboard/DailyOverview'; // Corrected import
import OrderManagement from '../../components/OrderManagement'; // Corrected import
import ClientManagement from '../../components/ClientManagement'; // Corrected import
import InvoiceManagement from '../../components/SecretaryDashboard/InvoiceManagement'; // Corrected import
import Schedule from '../../components/SecretaryDashboard/Schedule'; // Corrected import
import styles from './style/SecretaryDashboard.module.css';

export const SecretaryDashboard: React.FC = () => {
  const [selectedView, setSelectedView] = useState('daily');

  const sidebarItems = [
    { icon: '/icons/daily.svg', label: 'Aperçu Quotidien', value: 'daily' },
    { icon: '/icons/orders.svg', label: 'Gestion des Commandes', value: 'orders' },
    { icon: '/icons/clients.svg', label: 'Clients', value: 'clients' },
    { icon: '/icons/invoices.svg', label: 'Factures', value: 'invoices' },
    { icon: '/icons/schedule.svg', label: 'Planning', value: 'schedule' }
  ];

  const renderContent = () => {
    switch(selectedView) {
      case 'orders':
        return <OrderManagement />;
      case 'clients':
        return <ClientManagement />;
      case 'invoices':
        return <InvoiceManagement />;
      case 'schedule':
        return <Schedule />;
      default:
        return <DailyOverview />;
    }
  };

  return (
    <DashboardLayout
      sidebarItems={sidebarItems}
      selectedView={selectedView}
      onViewChange={setSelectedView}
      userRole="Secretary"
    >
      <div className={styles.dashboardContent}>
        {renderContent()}
      </div>
    </DashboardLayout>
  );
};
