import React, { useState, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { DashboardLayout } from '../DashboardLayout/DashboardLayout';
import { Overview } from './views/Overview';
import { AdminManagement } from './views/AdminManagement';
import { AffilietesSettings } from './views/AffilietesManagement';
import { GlobalStats } from './views/GlobalStats';
import { GlobalFinance } from './views/GlobalFinance';
import { SystemConfig } from './views/SystemConfig';
import { PermissionManagement } from './views/PermissionManagement';
import { Settings } from './views/Settings';
import { AppDispatch, RootState } from '../../redux/store';
import { fetchDashboardMetrics } from '../../redux/slices/dashboardSlice';
import styles from '../style/MasterSuperAdminDashboard.module.css';

export const MasterSuperAdminDashboard: React.FC = () => {
  const [selectedView, setSelectedView] = useState('overview');
  const dispatch = useDispatch<AppDispatch>();
  const { status } = useSelector((state: RootState) => state.dashboard);

  useEffect(() => {
    if (status === 'idle') {
      dispatch(fetchDashboardMetrics());
    }
  }, [status, dispatch]);

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

  const renderContent = () => {
    if (status === 'loading') {
      return <div className={styles.loading}>Loading...</div>;
    }

    if (status === 'failed') {
      return <div className={styles.error}>Error loading dashboard data</div>;
    }

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
      onViewChange={setSelectedView}
      userRole="Master Super Admin"
    >
      <div className={styles.dashboardContent}>
        {renderContent()}
      </div>
    </DashboardLayout>
  );
};

export default MasterSuperAdminDashboard;
