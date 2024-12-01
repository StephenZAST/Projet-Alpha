import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import styles from './Dashboard.module.css';
import { Sidebar } from './components/Sidebar';
import { TopBar } from './topbar/TopBar';
import { useAuth } from '../auth/AuthContext';
import { AdminType, adminNavConfigs } from './types/adminTypes';

interface DashboardProps {
  onThemeToggle: () => void;
}

const Dashboard: React.FC<DashboardProps> = ({ onThemeToggle }) => {
  const { user } = useAuth();
  const adminType = (user?.adminType as AdminType) || 'CUSTOMER_SERVICE';
  const navConfig = adminNavConfigs[adminType];

  const loadView = (viewName: string) => {
    return React.lazy(() => import(`./views/${adminType}Views/${viewName}`));
  };

  return (
    <div className={styles.dashboardLayout}>
      <Sidebar navConfig={navConfig} />
      
      <main className={styles.mainContent}>
        <TopBar onThemeToggle={onThemeToggle} />
        
        <div className={styles.viewContainer}>
          <React.Suspense fallback={<div>Loading...</div>}>
            <Routes>
              {/* Default route redirects to the default path */}
              <Route 
                index 
                element={<Navigate to={navConfig.defaultPath} replace />} 
              />
              
              {/* Map all nav items to routes */}
              {navConfig.navItems.map((item) => {
                const ViewComponent = loadView(item.id.charAt(0).toUpperCase() + item.id.slice(1));
                return (
                  <Route
                    key={item.id}
                    path={item.path}
                    element={
                      <React.Suspense fallback={<div>Loading view...</div>}>
                        <ViewComponent />
                      </React.Suspense>
                    }
                  />
                );
              })}
              
              {/* Catch all unmatched routes */}
              <Route 
                path="*" 
                element={<Navigate to={navConfig.defaultPath} replace />} 
              />
            </Routes>
          </React.Suspense>
        </div>
      </main>
    </div>
  );
};

export default Dashboard;
