import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import { Layout } from './components/layout/Layout';
import { Login } from './pages/auth/Login';
import { PrivateRoute } from './routes/PrivateRoute';
import { RoleGuard } from './components/guards/RoleGuard';
import { Unauthorized } from './pages/Unauthorized';

// Import your pages
import { AdminDashboard } from './pages/dashboard/AdminDashboard';
import { OrdersList } from './pages/orders/OrdersList';
import { UsersList } from './pages/users/UsersList';
import { ServicesList } from './pages/services/ServicesList';
import { ArticlesList } from './pages/articles/ArticlesList';
import { OrderDetails } from './pages/orders/OrderDetails';
import { AffiliatesList } from './pages/affiliates/AffiliatesList';
import { AffiliateDetails } from './pages/affiliates/AffiliateDetails';
import { DashboardRouter } from './pages/dashboard/DashboardRouter';
import { AnalyticsDashboard } from './pages/analytics/AnalyticsDashboard';

export const App = () => {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          {/* Public routes */}
          <Route path="/login" element={<Login />} />
          <Route path="/" element={<Navigate to="/dashboard" replace />} />

          {/* Error routes */}
          <Route path="/unauthorized" element={<Unauthorized />} />

          {/* Protected routes */}
          <Route element={<PrivateRoute />}>
            <Route element={<Layout />}>
              <Route path="/dashboard" element={<DashboardRouter />} />
              <Route path="/orders" element={
                <RoleGuard allowedRoles={['SUPER_ADMIN', 'ADMIN', 'DELIVERY']} resource="orders" action="read">
                  <OrdersList />
                </RoleGuard>
              } />
              <Route path="/users" element={
                <RoleGuard allowedRoles={['SUPER_ADMIN']} resource="users" action="read">
                  <UsersList />
                </RoleGuard>
              } />
              <Route path="/services" element={<ServicesList />} />
              <Route path="/articles" element={<ArticlesList />} />
              <Route path="/orders/:id" element={<OrderDetails />} />
              <Route path="/affiliates" element={
                <RoleGuard allowedRoles={['SUPER_ADMIN', 'ADMIN']} resource="affiliates" action="read">
                  <AffiliatesList />
                </RoleGuard>
              } />
              <Route path="/affiliates/:id" element={<AffiliateDetails />} />
              <Route path="/analytics" element={
                <RoleGuard allowedRoles={['SUPER_ADMIN', 'ADMIN']} resource="analytics" action="read">
                  <AnalyticsDashboard />
                </RoleGuard>
              } />
            </Route>
          </Route>

          {/* Catch all route */}
          <Route path="*" element={<Navigate to="/dashboard" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
};

export default App;