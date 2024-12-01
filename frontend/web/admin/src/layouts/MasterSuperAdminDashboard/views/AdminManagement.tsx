import React from 'react';
import { MetricCard } from '../../../components/MetricCard';
import { Table } from '../../../components/Table';
import styles from '../styles/AdminManagement.module.css';

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

  const mockAdminData = [
    {
      id: 1,
      adminName: "Jean Dupont",
      roleLevel: "Super Admin",
      associatedCompany: "Headquarters",
      lastActive: "2023-11-28 14:30",
      status: "Active",
      actions: "Edit | Delete"
    },
    {
      id: 2,
      adminName: "Marie Lambert",
      roleLevel: "Regional Admin",
      associatedCompany: "Europe Division",
      lastActive: "2023-11-28 12:15",
      status: "Active",
      actions: "Edit | Delete"
    },
    {
      id: 3,
      adminName: "Pierre Martin",
      roleLevel: "Local Admin",
      associatedCompany: "Paris Branch",
      lastActive: "2023-11-27 16:45",
      status: "Inactive",
      actions: "Edit | Delete"
    },
    {
      id: 4,
      adminName: "Sophie Bernard",
      roleLevel: "Department Admin",
      associatedCompany: "Sales Department",
      lastActive: "2023-11-28 09:20",
      status: "Active",
      actions: "Edit | Delete"
    }
  ];

  const mockActivityLog = [
    {
      id: 1,
      timestamp: "2023-11-28 14:30",
      action: "User login",
      admin: "Jean Dupont",
      details: "Successful login from IP 192.168.1.1"
    },
    {
      id: 2,
      timestamp: "2023-11-28 13:15",
      action: "Permission update",
      admin: "Marie Lambert",
      details: "Modified access rights for Sales Department"
    },
    {
      id: 3,
      timestamp: "2023-11-28 11:45",
      action: "New admin created",
      admin: "Pierre Martin",
      details: "Created new local admin account"
    }
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
          data={mockAdminData}
          onSearch={(value) => console.log('Search:', value)}
          onSort={(field) => console.log('Sort by:', field)}
          title="Gestion des Administrateurs"
        />
      </section>

      <section className={styles.activityLog}>
        <div className={styles.activityLogHeader}>
          <h3>Activity Log</h3>
        </div>
        <div className={styles.activityLogContent}>
          {mockActivityLog.map((activity) => (
            <div key={activity.id} className={styles.activityItem}>
              <span className={styles.timestamp}>{activity.timestamp}</span>
              <span className={styles.action}>{activity.action}</span>
              <span className={styles.admin}>{activity.admin}</span>
              <span className={styles.details}>{activity.details}</span>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
};
