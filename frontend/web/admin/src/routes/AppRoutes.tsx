import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { Permission } from '../utils/permissions';
import ProtectedRoute from '../components/auth/ProtectedRoute';

// Layouts
import AdminLayout from '../layouts/admin/AdminLayout';

// Auth Pages
import Login from '../pages/auth/Login';
import ForgotPassword from '../pages/auth/ForgotPassword';

// Admin Pages
import Dashboard from '../pages/admin/master-super-admin/views/Dashboard';
import AdminManagement from '../pages/admin/master-super-admin/views/AdminManagement';
import Permissions from '../pages/admin/master-super-admin/views/Permissions';
import SystemLogs from '../pages/admin/master-super-admin/views/SystemLogs';
import Unauthorized from '../pages/error/Unauthorized';

const AppRoutes: React.FC = () => {
  return (
    <Routes>
      {/* Public Routes */}
      <Route path="/login" element={<Login />} />
      <Route path="/forgot-password" element={<ForgotPassword />} />
      <Route path="/unauthorized" element={<Unauthorized />} />

      {/* Protected Routes */}
      <Route
        path="/"
        element={
          <ProtectedRoute>
            <AdminLayout />
          </ProtectedRoute>
        }
      >
        <Route index element={<Navigate to="/dashboard" replace />} />
        
        <Route
          path="dashboard"
          element={
            <ProtectedRoute requiredPermissions={[Permission.ADMIN_READ]}>
              <Dashboard />
            </ProtectedRoute>
          }
        />

        <Route
          path="admin-management"
          element={
            <ProtectedRoute
              requiredPermissions={[Permission.ADMIN_READ, Permission.ADMIN_CREATE]}
            >
              <AdminManagement />
            </ProtectedRoute>
          }
        />

        <Route
          path="permissions"
          element={
            <ProtectedRoute
              requiredPermissions={[Permission.SYSTEM_SETTINGS]}
            >
              <Permissions />
            </ProtectedRoute>
          }
        />

        <Route
          path="system-logs"
          element={
            <ProtectedRoute requiredPermissions={[Permission.SYSTEM_LOGS]}>
              <SystemLogs />
            </ProtectedRoute>
          }
        />
      </Route>

      {/* Catch all route */}
      <Route path="*" element={<Navigate to="/dashboard" replace />} />
    </Routes>
  );
};

export default AppRoutes;
