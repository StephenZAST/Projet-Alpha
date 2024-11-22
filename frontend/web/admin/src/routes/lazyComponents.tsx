import { lazy } from 'react';

// Layouts
export const AdminLayout = lazy(() => import('../layouts/admin/AdminLayout'));

// Pages
export const Dashboard = lazy(() => import('../pages/admin/master-super-admin/views/Dashboard'));
export const AdminManagement = lazy(() => import('../pages/admin/master-super-admin/views/AdminManagement'));
export const Permissions = lazy(() => import('../pages/admin/master-super-admin/views/Permissions'));
export const SystemLogs = lazy(() => import('../pages/admin/master-super-admin/views/SystemLogs'));
export const Login = lazy(() => import('../pages/auth/Login'));
export const ForgotPassword = lazy(() => import('../pages/auth/ForgotPassword'));
export const ResetPassword = lazy(() => import('../pages/auth/ResetPassword'));
