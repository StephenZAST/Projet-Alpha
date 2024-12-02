import React, { Suspense } from 'react';
import { Routes, Route, Navigate, useLocation } from 'react-router-dom';
import styles from './Dashboard.module.css';
import { Sidebar } from './components/Sidebar';
import { TopBar } from './topbar/TopBar';
import { useAuth } from '../auth/AuthContext';
import { adminNavConfigs } from './types/adminTypes';

// Import des vues Master Super Admin
const MasterSuperAdminViews = {
  'overview': React.lazy(() => import('./views/MasterSuperAdminViews/Overview')),
  'admin-management': React.lazy(() => import('./views/MasterSuperAdminViews/AdminManagement')),
  'company-management': React.lazy(() => import('./views/MasterSuperAdminViews/Company')),
  'global-stats': React.lazy(() => import('./views/MasterSuperAdminViews/GlobalStats')),
  'system-settings': React.lazy(() => import('./views/MasterSuperAdminViews/Settings'))
};

// Import des vues Super Admin
const SuperAdminViews = {
  'overview': React.lazy(() => import('./views/SuperAdminViews/Overview')),
  'user-management': React.lazy(() => import('./views/SuperAdminViews/UserManagement')),
  'content-management': React.lazy(() => import('./views/SuperAdminViews/ContentManagement')),
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
  const location = useLocation();
  const adminType = (user?.adminType as keyof typeof ViewsMap) || 'CUSTOMER_SERVICE';
  const navConfig = adminNavConfigs[adminType];

  // Log pour le débogage
  console.log('Current location:', location.pathname);
  console.log('Admin type:', adminType);
  console.log('Nav config:', navConfig);

  return (
    <div className={styles.dashboardLayout}>
      <div className={styles.sidebar}>
        <Sidebar navConfig={navConfig} />
      </div>
      
      <main className={styles.mainContent}>
        <TopBar onThemeToggle={onThemeToggle} />
        
        <div className={styles.viewContainer}>
          <Suspense fallback={<div>Loading...</div>}>
            <Routes>
              {/* Route par défaut */}
              <Route 
                index
                element={<Navigate to={navConfig.defaultPath} replace />} 
              />
              
              {/* Routes dynamiques basées sur la configuration */}
              {navConfig.navItems.map((item) => {
                const views = ViewsMap[adminType];
                const ViewComponent = views[item.path as keyof typeof views];
                
                return ViewComponent ? (
                  <Route
                    key={item.id}
                    path={item.path}
                    element={<ViewComponent />}
                  />
                ) : null;
              })}

              {/* Redirection pour les routes non trouvées */}
              <Route 
                path="*" 
                element={<Navigate to={navConfig.defaultPath} replace />} 
              />
            </Routes>
          </Suspense>
        </div>
      </main>
    </div>
  );
};

export default Dashboard;
