import React, { useMemo } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import styles from './Dashboard.module.css';
import { Sidebar } from './components/Sidebar';
import { TopBar } from './topbar/TopBar';
import { useAuth } from '../auth/AuthContext';
import { AdminType, adminNavConfigs } from './types/adminTypes';

// Import des vues Master Super Admin
const MasterSuperAdminViews = {
  'overview': React.lazy(() => import('./views/MasterSuperAdminViews/Overview')),
  'admin-management': React.lazy(() => import('./views/MasterSuperAdminViews/AdminManagement')),
  'company': React.lazy(() => import('./views/MasterSuperAdminViews/Company')),
  'global-stats': React.lazy(() => import('./views/MasterSuperAdminViews/GlobalStats')),
  'settings': React.lazy(() => import('./views/MasterSuperAdminViews/Settings'))
};

// Import des vues Super Admin
const SuperAdminViews = {
  'overview': React.lazy(() => import('./views/SuperAdminViews/Overview')),
  'user-management': React.lazy(() => import('./views/SuperAdminViews/UserManagement')),
  'content': React.lazy(() => import('./views/SuperAdminViews/ContentManagement')),
  'reports': React.lazy(() => import('./views/SuperAdminViews/Reports'))
};

// Mapping des vues par type d'admin
const ViewsMap = {
  MASTER_SUPER_ADMIN: MasterSuperAdminViews,
  SUPER_ADMIN: SuperAdminViews
} as const;

interface DashboardProps {
  onThemeToggle: () => void;
}

const Dashboard: React.FC<DashboardProps> = ({ onThemeToggle }) => {
  const { user } = useAuth();
  const adminType = (user?.adminType as keyof typeof ViewsMap) || 'CUSTOMER_SERVICE';
  const navConfig = adminNavConfigs[adminType];

  const getViewComponent = (viewId: string) => {
    const views = ViewsMap[adminType];
    if (!views) {
      console.error(`No views found for admin type: ${adminType}`);
      return React.lazy(() => Promise.resolve({
        default: () => <div>No views available for this admin type</div>
      }));
    }

    const ViewComponent = views[viewId as keyof typeof views];
    if (!ViewComponent) {
      console.error(`View not found: ${viewId} for admin type: ${adminType}`);
      return React.lazy(() => Promise.resolve({
        default: () => <div>View not found: {viewId}</div>
      }));
    }

    return ViewComponent;
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
    [navConfig.navItems, adminType]
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
