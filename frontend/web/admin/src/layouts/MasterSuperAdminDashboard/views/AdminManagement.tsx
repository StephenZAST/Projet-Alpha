import React from 'react';
import { MetricCard } from '../../../components/MetricCard';
import { Table } from '../../../components/Table';
import styles from './styles/AdminManagement.module.css';

export const AdminManagement: React.FC = () => {
  
  const adminMetrics = [
    {
      title: "Total Admins",
      value: "234",
      change: { value: "+12", type: 'increase' as const, baseline: "ce mois" }
    },
    {
      title: "Active Admins",
      value: "189",
      change: { value: "+5", type: 'increase' as const, baseline: "cette semaine" }
    },
    {
      title: "Pending Approvals",
      value: "15",
      change: { value: "-3", type: 'decrease' as const, baseline: "vs hier" }
    }
  ];

  const adminTableHeaders = [
    "Admin Name",
    "Role Level",
    "Associated Company",
    "Last Active",
    "Status",
    "Actions"
  ];

  return (
    <div className={styles.adminManagementContainer}>
      <section className={styles.metricsSection}>
        {adminMetrics.map((metric, index) => (
          <MetricCard key={index} {...metric} />
        ))}
      </section>

      <section className={styles.mainContent}>
        <Table
          headers={adminTableHeaders}
          data={[]} // Will be populated with real data
          onSearch={(value) => console.log('Search:', value)}
          onSort={(field) => console.log('Sort by:', field)}
          title="Gestion des Administrateurs"
        />
      </section>

      <section className={styles.activityLog}>
        {/* Activity Log Component will go here */}
      </section>
    </div>
  );
};
