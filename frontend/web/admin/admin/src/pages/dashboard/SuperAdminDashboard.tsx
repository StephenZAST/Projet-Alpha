import { useState, useEffect } from 'react';
import { DashboardMetrics } from '../../components/dashboard/DashboardMetrics';
import { useAdmin } from '../../hooks/useAdmin';
import { colors } from '../../theme/colors';

export const SuperAdminDashboard = () => {
  const { stats, loading, error } = useAdmin();

  if (loading) return <div>Loading dashboard data...</div>;
  if (error) return <div style={{ color: colors.error }}>{error}</div>;

  return (
    <div style={{ padding: '24px' }}>
      <h1 style={{ marginBottom: '24px' }}>Super Admin Dashboard</h1>
      <DashboardMetrics role="SUPER_ADMIN" metrics={stats} />
      {/* Add additional super admin specific components */}
    </div>
  );
};