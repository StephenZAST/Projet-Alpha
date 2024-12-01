import React, { useMemo } from 'react';
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

  const getViewComponent = (viewId: string) => {
    // Convertir l'ID en format PascalCase pour le nom du fichier
    const viewName = viewId
      .split(/[-_]/)
      .map(part => part.charAt(0).toUpperCase() + part.slice(1))
      .join('');

    console.log('Loading view:', viewName, 'for admin type:', adminType);
    
    return React.lazy(() => 
      import(`./views/${adminType}Views/${viewName}`)
        .catch(error => {
          console.error(`Error loading view ${viewName}:`, error);
          return { default: () => <div>Error loading view {viewName}</div> };
        })
    );
  };

  const routes = useMemo(() => 
    navConfig.navItems.map(item => {
      const ViewComponent = getViewComponent(item.id);
      return {
        key: item.id,
        path: item.path,
        element: (
          <React.Suspense fallback={<div>Loading view...</div>}>
            <ViewComponent />
          </React.Suspense>
        )
      };
    }),
    [navConfig.navItems]
  );

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
              {routes.map(route => (
                <Route
                  key={route.key}
                  path={route.path}
                  element={route.element}
                />
              ))}
              
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
