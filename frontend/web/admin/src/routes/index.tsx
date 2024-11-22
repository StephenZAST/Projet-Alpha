import { RouteObject } from 'react-router-dom';
import {
  AdminLayout,
  Dashboard,
  AdminManagement,
  Permissions,
  SystemLogs,
  Login,
  ForgotPassword,
  ResetPassword
} from './lazyComponents';
import { Suspense } from 'react';

// Composant de chargement
// eslint-disable-next-line react-refresh/only-export-components
const LoadingComponent = () => (
  <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
    Loading...
  </div>
);

export const routes: RouteObject[] = [
  {
    path: '/auth',
    children: [
      {
        path: 'login',
        element: (
          <Suspense fallback={<LoadingComponent />}>
            <Login />
          </Suspense>
        ),
      },
      {
        path: 'forgot-password',
        element: (
          <Suspense fallback={<LoadingComponent />}>
            <ForgotPassword />
          </Suspense>
        ),
      },
      {
        path: 'reset-password/:token',
        element: (
          <Suspense fallback={<LoadingComponent />}>
            <ResetPassword />
          </Suspense>
        ),
      },
    ],
  },
  {
    path: '/',
    element: (
      <Suspense fallback={<LoadingComponent />}>
        <AdminLayout />
      </Suspense>
    ),
    children: [
      {
        path: 'dashboard',
        element: (
          <Suspense fallback={<LoadingComponent />}>
            <Dashboard />
          </Suspense>
        ),
      },
      {
        path: 'admin-management',
        element: (
          <Suspense fallback={<LoadingComponent />}>
            <AdminManagement />
          </Suspense>
        ),
      },
      {
        path: 'permissions',
        element: (
          <Suspense fallback={<LoadingComponent />}>
            <Permissions />
          </Suspense>
        ),
      },
      {
        path: 'system-logs',
        element: (
          <Suspense fallback={<LoadingComponent />}>
            <SystemLogs />
          </Suspense>
        ),
      },
    ],
  },
];
