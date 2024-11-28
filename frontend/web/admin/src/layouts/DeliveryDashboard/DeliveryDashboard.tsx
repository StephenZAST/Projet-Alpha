import React, { useState } from 'react';
import { DashboardLayout } from '../DashboardLayout/DashboardLayout';
import DeliveryList from '../../components/DeliveryDashboard/DeliveryList';
import NavigationMap from '../../components/DeliveryDashboard/NavigationMap';
import CustomerContact from '../../components/CustomerContact';
import DeliveryReports from '../../components/DeliveryDashboard/DeliveryReports';
import styles from './style/DeliveryDashboard.module.css';

export const DeliveryDashboard: React.FC = () => {
  const [selectedView, setSelectedView] = useState('deliveries');

  const sidebarItems = [
    { icon: '/icons/delivery.svg', label: 'Mes Livraisons', value: 'deliveries' },
    { icon: '/icons/navigation.svg', label: 'Navigation', value: 'navigation' },
    { icon: '/icons/contact.svg', label: 'Contact Client', value: 'contact' },
    { icon: '/icons/reports.svg', label: 'Rapports', value: 'reports' }
  ];

  const renderContent = () => {
    switch(selectedView) {
      case 'navigation':
        return <NavigationMap />;
      case 'contact':
        return <CustomerContact />;
      case 'reports':
        return <DeliveryReports />;
      default:
        return <DeliveryList />;
    }
  };

  return (
    <DashboardLayout
      sidebarItems={sidebarItems}
      selectedView={selectedView}
      onViewChange={setSelectedView}
      userRole="Delivery Person"
    >
      <div className={styles.dashboardContent}>
        {renderContent()}
      </div>
    </DashboardLayout>
  );
};
