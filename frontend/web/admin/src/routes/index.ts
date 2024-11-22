import { RouteObject } from 'react-router-dom';
import { lazy } from 'react';

// Layouts
const AdminLayout = lazy(() => import('../layouts/admin/AdminLayout'));

// Pages
const Dashboard = lazy(() => import('../pages/admin/master-super-admin/views/Dashboard'));
const AdminManagement = lazy(() => import('../pages/admin/master-super-admin/views/AdminManagement'));
const Permissions = lazy(() => import('../pages/admin/master-super-admin/views/Permissions'));
const SystemLogs = lazy(() => import('../pages/admin/master-super-admin/views/SystemLogs'));

export const routes: RouteObject[] = [
  {
    path: '/',
    element: <AdminLayout />,
    children: [
      {
        path: 'dashboard',
        element: <Dashboard />,
      },
      {
        path: 'admin-management',
        element: <AdminManagement />,
      },
      {
        path: 'permissions',
        element: <Permissions />,
      },
      {
        path: 'system-logs',
        element: <SystemLogs />,
      },
    ],
  },
];
