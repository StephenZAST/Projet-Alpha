import React, { useState } from 'react';
import { DashboardLayout } from '../DashboardLayout/DashboardLayout';
import { Overview } from './views/Overview';
import { AdminManagement } from './views/AdminManagement';
import { AffilietesSettings } from './views/AffilietesManagement';
import { GlobalStats } from './views/GlobalStats';
import { GlobalFinance } from './views/GlobalFinance';
import { SystemConfig } from './views/SystemConfig';
import { PermissionManagement } from './views/PermissionManagement';
import { Settings } from './views/Settings';
import styles from '../style/MasterSuperAdminDashboard.module.css';

export const MasterSuperAdminDashboard: React.FC = () => {
  const [selectedView, setSelectedView] = useState<string>('overview');

  const sidebarItems = [
    { 
      icon: '/icons/overview.svg', 
      label: 'Vue d\'ensemble', 
      value: 'overview' 
    },
    { 
      icon: '/icons/admin.svg', 
      label: 'Gestion des Administrateurs', 
      value: 'admins' 
    },
    { 
      icon: '/icons/company.svg', 
      label: 'Gestion des Entreprises', 
      value: 'companies' 
    },
    { 
      icon: '/icons/stats.svg', 
      label: 'Statistiques Globales', 
      value: 'stats' 
    },
    { 
      icon: '/icons/finance.svg', 
      label: 'Finance Globale', 
      value: 'finance' 
    },
    { 
      icon: '/icons/config.svg', 
      label: 'Configuration Système', 
      value: 'config' 
    },
    { 
      icon: '/icons/permissions.svg', 
      label: 'Gestion des Permissions', 
      value: 'permissions' 
    },
    { 
      icon: '/icons/settings.svg', 
      label: 'Paramètres', 
      value: 'settings' 
    }
  ];

  const handleViewChange = (view: string) => {
    setSelectedView(view);
  };

  const renderContent = () => {
    switch(selectedView) {
      case 'overview':
        return <Overview />;
      case 'admins':
        return <AdminManagement />;
      case 'companies':
        return <AffilietesSettings />;
      case 'stats':
        return <GlobalStats />;
      case 'finance':
        return <GlobalFinance />;
      case 'config':
        return <SystemConfig />;
      case 'permissions':
        return <PermissionManagement />;
      case 'settings':
        return <Settings />;
      default:
        return <Overview />;
    }
  };

  return (
    <DashboardLayout
      sidebarItems={sidebarItems}
      selectedView={selectedView}
      onViewChange={handleViewChange}
      userRole="superAdmin"
    >
      <div className={styles.dashboardContent}>
        {renderContent()}
      </div>
    </DashboardLayout>
  );
};

export default MasterSuperAdminDashboard;
