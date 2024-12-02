import React, { Suspense } from 'react';
import { Outlet } from '@tanstack/react-router';
import styles from './Dashboard.module.css';
import { Sidebar } from './components/Sidebar';
import { TopBar } from './topbar/TopBar';
import { useAuth } from '../auth/AuthContext';
import { adminNavConfigs } from './types/adminTypes';

const Dashboard: React.FC = () => {
  const { user } = useAuth();
  const adminType = (user?.adminType as keyof typeof adminNavConfigs) || 'CUSTOMER_SERVICE';
  const navConfig = adminNavConfigs[adminType];

  return (
    <div className={styles.dashboardLayout}>
      <Sidebar navConfig={navConfig} />
      
      <main className={styles.mainContent}>
        <TopBar />
        <div className={styles.viewContainer}>
          <Suspense fallback={<div>Loading...</div>}>
            <Outlet />
          </Suspense>
        </div>
      </main>
    </div>
  );
};

export default Dashboard;
