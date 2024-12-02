import { Router, createRootRoute, createRoute } from '@tanstack/react-router';
import { lazy } from 'react';
import App from './App';
import { adminNavConfigs } from './dashboard/types/adminTypes';

// Définir les types pour nos routes
type RouteImport = () => Promise<any>;

type MasterSuperAdminRoutes = {
  overview: RouteImport;
  adminManagement: RouteImport;
  companyManagement: RouteImport;
  globalStats: RouteImport;
  systemSettings: RouteImport;
};

type SuperAdminRoutes = {
  overview: RouteImport;
  userManagement: RouteImport;
  contentManagement: RouteImport;
  reports: RouteImport;
};

interface AdminRoutes {
  masterSuperAdmin: MasterSuperAdminRoutes;
  superAdmin: SuperAdminRoutes;
}

// Fonction helper pour vérifier si une clé existe dans les routes
function isValidRouteKey(
  adminType: 'masterSuperAdmin' | 'superAdmin',
  key: string
): key is keyof MasterSuperAdminRoutes | keyof SuperAdminRoutes {
  if (adminType === 'masterSuperAdmin') {
    return key in routes.masterSuperAdmin;
  }
  return key in routes.superAdmin;
}

// Mapping des chemins URL vers les clés de route
const pathToRouteKey = {
  'overview': 'overview',
  'admin-management': 'adminManagement',
  'company-management': 'companyManagement',
  'global-stats': 'globalStats',
  'system-settings': 'systemSettings',
  'user-management': 'userManagement',
  'content-management': 'contentManagement',
  'reports': 'reports'
} as const;

// Créer les routes avec le typage correct
const routes: AdminRoutes = {
  masterSuperAdmin: {
    overview: () => import('./dashboard/views/MasterSuperAdminViews/Overview'),
    adminManagement: () => import('./dashboard/views/MasterSuperAdminViews/AdminManagement'),
    companyManagement: () => import('./dashboard/views/MasterSuperAdminViews/Company'),
    globalStats: () => import('./dashboard/views/MasterSuperAdminViews/GlobalStats'),
    systemSettings: () => import('./dashboard/views/MasterSuperAdminViews/Settings')
  },
  superAdmin: {
    overview: () => import('./dashboard/views/SuperAdminViews/Overview'),
    userManagement: () => import('./dashboard/views/SuperAdminViews/UserManagement'),
    contentManagement: () => import('./dashboard/views/SuperAdminViews/ContentManagement'),
    reports: () => import('./dashboard/views/SuperAdminViews/Reports')
  }
};

// Route racine
const rootRoute = createRootRoute({
  component: App,
});

// Route du tableau de bord
const dashboardRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: 'dashboard',
  component: lazy(() => import('./dashboard/Dashboard')),
});

// Créer les routes pour chaque type d'admin
const adminRoutes = Object.entries(adminNavConfigs).flatMap(([adminType, config]) => {
  return config.navItems.map((item) => {
    const adminKey = adminType === 'MASTER_SUPER_ADMIN' ? 'masterSuperAdmin' : 'superAdmin';
    const routeKey = pathToRouteKey[item.path as keyof typeof pathToRouteKey];
    
    if (!routeKey || !isValidRouteKey(adminKey, routeKey)) {
      console.warn(`Route non trouvée pour ${item.path}`);
      return null;
    }

    const routeComponent = routes[adminKey][routeKey];
    
    return createRoute({
      getParentRoute: () => dashboardRoute,
      path: item.path,
      component: lazy(routeComponent),
    });
  }).filter((route): route is NonNullable<typeof route> => route !== null);
});

// Créer et exporter le routeur
const routeTree = rootRoute.addChildren([
  dashboardRoute.addChildren(adminRoutes)
]);

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router;
  }
}

export const router = new Router({
  routeTree,
  defaultPreload: 'intent',
});
