import React, { useState } from 'react';
import { MetricCard } from '../components/MetricCard';
import { AdminTable } from '../components/AdminTable';
import { CompanyMetrics } from '../components/CompanyMetrics';
import { SystemAlerts } from '../components/SystemAlerts';
import { DashboardLayout } from './DashboardLayout';
import { AdminActivityLog } from '../components/AdminActivityLog';
import styles from './style/MasterSuperAdminDashboard.module.css';

export const MasterSuperAdminDashboard: React.FC = () => {
  const [selectedView, setSelectedView] = useState('overview');

  const sidebarItems = [
    { icon: '/icons/overview.svg', label: 'Vue d\'ensemble', value: 'overview' },
    { icon: '/icons/admin.svg', label: 'Gestion des Administrateurs', value: 'admins' },
    { icon: '/icons/company.svg', label: 'Gestion des Entreprises', value: 'companies' },
    { icon: '/icons/stats.svg', label: 'Statistiques Globales', value: 'stats' },
    { icon: '/icons/config.svg', label: 'Configuration Système', value: 'config' },
    { icon: '/icons/permissions.svg', label: 'Gestion des Permissions', value: 'permissions' },
    { icon: '/icons/finance.svg', label: 'Finance Globale', value: 'finance' }
  ];

  const metrics = [
    {
      title: "Total Commandes",
      value: "12,456",
      change: { value: "+23%", type: "increase", baseline: "vs last month" }
    },
    {
      title: "Revenus Globaux",
      value: "€234,567",
      change: { value: "+15%", type: "increase", baseline: "vs last month" }
    },
    {
      title: "Utilisateurs Actifs",
      value: "8,892",
      change: { value: "+5%", type: "increase", baseline: "vs last week" }
    },
    {
      title: "Taux de Conversion",
      value: "2.4%",
      change: { value: "-0.2%", type: "decrease", baseline: "vs last week" }
    }
  ];

  return (
    <DashboardLayout 
      sidebarItems={sidebarItems}
      selectedView={selectedView}
      onViewChange={setSelectedView}
      userRole="Master Super Admin"
    >
      <div className={styles.dashboardContent}>
        <section className={styles.metricsGrid}>
          {metrics.map((metric, index) => (
            <MetricCard key={index} {...metric} />
          ))}
        </section>

        <div className={styles.mainContent}>
          <section className={styles.primaryContent}>
            <CompanyMetrics />
            <SystemAlerts />
          </section>

          <aside className={styles.secondaryContent}>
            <AdminActivityLog />
          </aside>
        </div>

        {selectedView === 'admins' && <AdminTable />}
      </div>
    </DashboardLayout>
  );
};