import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import styles from './Dashboard.module.css';
import { Sidebar } from './components/Sidebar';
import { TopBar } from './topbar/TopBar';
import { useAuth } from '../auth/AuthContext';
import { AdminType, adminNavConfigs } from './types/adminTypes';
import ErrorBoundary from '../components/ErrorBoundary';

// Import statique des vues pour chaque type d'admin
const MasterSuperAdminViews = {
  Overview: React.lazy(() => import('./views/MasterSuperAdminViews/Overview')),
  'Admin-management': React.lazy(() => import('./views/MasterSuperAdminViews/AdminManagement')),
  Company: React.lazy(() => import('./views/MasterSuperAdminViews/Company')),
  'Global-stats': React.lazy(() => import('./views/MasterSuperAdminViews/Analytics')),
  Settings: React.lazy(() => import('./views/MasterSuperAdminViews/SystemSettings'))
} as const;

const SuperAdminViews = {
  Overview: React.lazy(() => import('./views/SuperAdminViews/Overview')),
  'User-management': React.lazy(() => import('./views/SuperAdminViews/UserManagement')),
  Content: React.lazy(() => import('./views/SuperAdminViews/ContentManagement')),
  Reports: React.lazy(() => import('./views/SuperAdminViews/Reports'))
} as const;

const ViewComponents = {
  MASTER_SUPER_ADMIN: MasterSuperAdminViews,
  SUPER_ADMIN: SuperAdminViews
} as const;

interface DashboardProps {
  onThemeToggle: () => void;
}

const Dashboard: React.FC<DashboardProps> = ({ onThemeToggle }) => {
  const { user } = useAuth();
  const adminType = (user?.adminType as keyof typeof ViewComponents) || 'CUSTOMER_SERVICE';
  const navConfig = adminNavConfigs[adminType];

  const getViewComponent = (viewId: string) => {
    const views = ViewComponents[adminType as keyof typeof ViewComponents];
    if (!views) {
      console.error(`No views found for admin type: ${adminType}`);
      return null;
    }

    const ViewComponent = views[viewId as keyof typeof views];
    if (!ViewComponent) {
      console.error(`View not found: ${viewId} for admin type: ${adminType}`);
      return null;
    }

    return ViewComponent;
  };

  return (
    <div className={styles.dashboardLayout}>
      <Sidebar navConfig={navConfig} />
      
      <main className={styles.mainContent}>
        <TopBar onThemeToggle={onThemeToggle} />
        
        <div className={styles.viewContainer}>
          <ErrorBoundary>
            <React.Suspense fallback={<div>Loading...</div>}>
              <Routes>
                {/* Default route redirects to the default path */}
                <Route 
                  index 
                  element={<Navigate to={navConfig.defaultPath} replace />} 
                />
                
                {/* Map all nav items to routes */}
                {navConfig.navItems.map((item) => {
                  const viewId = item.id;
                  const ViewComponent = getViewComponent(viewId);
                  
                  if (!ViewComponent) {
                    console.warn(`Skipping route for ${viewId} - component not found`);
                    return null;
                  }

                  return (
                    <Route
                      key={item.id}
                      path={item.path}
                      element={
                        <ErrorBoundary>
                          <React.Suspense fallback={<div>Loading view...</div>}>
                            <ViewComponent />
                          </React.Suspense>
                        </ErrorBoundary>
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
          </ErrorBoundary>
        </div>
      </main>
    </div>
  );
};

export default Dashboard;
