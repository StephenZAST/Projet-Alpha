import { RouteObject } from 'react-router-dom';
import { lazy } from 'react';

// Layouts
const AdminLayout = lazy(() => import('../layouts/admin/AdminLayout'));

// Pages
const Dashboard = lazy(() => import('../pages/admin/master-super-admin/views/Dashboard'));
const AdminManagement = lazy(() => import('../pages/admin/master-super-admin/views/AdminManagement'));
const Permissions = lazy(() => import('../pages/admin/master-super-admin/views/Permissions'));
const SystemLogs = lazy(() => import('../pages/admin/master-super-admin/views/SystemLogs'));
const Login = lazy(() => import('../pages/auth/Login'));
const ForgotPassword = lazy(() => import('../pages/auth/ForgotPassword'));
const ResetPassword = lazy(() => import('../pages/auth/ResetPassword'));

export const routes: RouteObject[] = [
  {
    path: '/auth',
    children: [
      {
        path: 'login',
        element: <Login />,
      },
      {
        path: 'forgot-password',
        element: <ForgotPassword />,
      },
      {
        path: 'reset-password/:token',
        element: <ResetPassword />,
      },
    ],
  },
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
