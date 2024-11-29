import React from 'react';
import { MetricCard } from '../../../components/MetricCard';
import { Table } from '../../../components/Table';
import styles from '../styles/PermissionManagement.module.css';

export const PermissionManagement: React.FC = () => {
  const permissionMetrics = [
    {
      title: "Total Roles",
      value: "8",
      change: { value: "+1", type: 'increase' as const, baseline: "nouveau rôle" }
    },
    {
      title: "Active Permissions",
      value: "156",
      change: { value: "+12", type: 'increase' as const, baseline: "ce mois" }
    },
    {
      title: "Permission Updates",
      value: "24",
      change: { value: "+5", type: 'increase' as const, baseline: "aujourd'hui" }
    }
  ];

  const roleHeaders = [
    "Role Name",
    "Access Level",
    "Users Count",
    "Last Modified",
    "Status",
    "Actions"
  ];

  return (
    <div className={styles.permissionContainer}>
      <section className={styles.metricsGrid}>
        {permissionMetrics.map((metric, index) => (
          <MetricCard key={index} {...metric} />
        ))}
      </section>

      <section className={styles.roleMatrix}>
        <div className={styles.matrixCard}>
          <h3>Matrice des Rôles</h3>
          <Table
            headers={roleHeaders}
            data={[]} // Will be populated with real data
            onSearch={(value) => console.log('Search:', value)}
            onSort={(field) => console.log('Sort by:', field)}
            title="Gestion des Rôles"
          />
        </div>
      </section>

      <section className={styles.permissionConfig}>
        <div className={styles.configCard}>
          <h3>Configuration des Accès</h3>
          <div className={styles.permissionGrid}>
            {/* Permission configuration interface */}
          </div>
        </div>
      </section>

      <section className={styles.auditLog}>
        <div className={styles.logCard}>
          <h3>Journal d'Audit</h3>
          {/* Audit log viewer component */}
        </div>
      </section>
    </div>
  );
};
