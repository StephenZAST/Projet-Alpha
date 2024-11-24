import React, { useState } from 'react';
import { DashboardLayout } from './DashboardLayout';
import { SupportTickets } from '../components/SupportTickets';
import { CustomerDatabase } from '../components/CustomerDatabase';
import { ServiceStatistics } from '../components/ServiceStatistics';
import { ServiceReports } from '../components/ServiceReports';
import styles from './CustomerServiceDashboard.module.css';

export const CustomerServiceDashboard: React.FC = () => {
  const [selectedView, setSelectedView] = useState('tickets');

  const sidebarItems = [
    { icon: '/icons/support.svg', label: 'Tickets Support', value: 'tickets' },
    { icon: '/icons/database.svg', label: 'Base Clients', value: 'database' },
    { icon: '/icons/stats.svg', label: 'Statistiques', value: 'stats' },
    { icon: '/icons/reports.svg', label: 'Rapports', value: 'reports' }
  ];

  const renderContent = () => {
    switch(selectedView) {
      case 'database':
        return <CustomerDatabase />;
      case 'stats':
        return <ServiceStatistics />;
      case 'reports':
        return <ServiceReports />;
      default:
        return <SupportTickets />;
    }
  };

  return (
    <DashboardLayout
      sidebarItems={sidebarItems}
      selectedView={selectedView}
      onViewChange={setSelectedView}
      userRole="Customer Service"
    >
      <div className={styles.dashboardContent}>
        {renderContent()}
      </div>
    </DashboardLayout>
  );
};