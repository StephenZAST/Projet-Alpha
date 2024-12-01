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

  const mockRoleData = [
    {
      id: 1,
      roleName: "Super Admin",
      accessLevel: "Full Access",
      usersCount: "5",
      lastModified: "2023-11-28",
      status: "Active",
      actions: "Edit | Delete"
    },
    {
      id: 2,
      roleName: "Regional Manager",
      accessLevel: "Regional Access",
      usersCount: "12",
      lastModified: "2023-11-27",
      status: "Active",
      actions: "Edit | Delete"
    },
    {
      id: 3,
      roleName: "Department Head",
      accessLevel: "Department Access",
      usersCount: "28",
      lastModified: "2023-11-26",
      status: "Active",
      actions: "Edit | Delete"
    },
    {
      id: 4,
      roleName: "Standard User",
      accessLevel: "Basic Access",
      usersCount: "156",
      lastModified: "2023-11-25",
      status: "Active",
      actions: "Edit | Delete"
    }
  ];

  const mockPermissionModules = [
    {
      id: 1,
      name: "User Management",
      permissions: ["View", "Create", "Edit", "Delete"]
    },
    {
      id: 2,
      name: "Financial Operations",
      permissions: ["View", "Approve", "Reject"]
    },
    {
      id: 3,
      name: "Reports",
      permissions: ["View", "Generate", "Export"]
    },
    {
      id: 4,
      name: "System Settings",
      permissions: ["View", "Modify"]
    }
  ];

  const mockAuditLog = [
    {
      id: 1,
      timestamp: "2023-11-28 14:30",
      user: "Jean Dupont",
      action: "Modified role permissions",
      details: "Updated Regional Manager access rights"
    },
    {
      id: 2,
      timestamp: "2023-11-28 13:15",
      user: "Marie Lambert",
      action: "Created new role",
      details: "Added Department Head role"
    },
    {
      id: 3,
      timestamp: "2023-11-28 11:45",
      user: "Pierre Martin",
      action: "Permission update",
      details: "Modified Standard User permissions"
    }
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
            data={mockRoleData}
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
            {mockPermissionModules.map((module) => (
              <div key={module.id} className={styles.moduleCard}>
                <h4>{module.name}</h4>
                <div className={styles.permissionList}>
                  {module.permissions.map((permission, index) => (
                    <div key={index} className={styles.permissionItem}>
                      <input type="checkbox" id={`${module.id}-${index}`} />
                      <label htmlFor={`${module.id}-${index}`}>{permission}</label>
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className={styles.auditLog}>
        <div className={styles.logCard}>
          <h3>Journal d'Audit</h3>
          <div className={styles.logEntries}>
            {mockAuditLog.map((entry) => (
              <div key={entry.id} className={styles.logEntry}>
                <span className={styles.timestamp}>{entry.timestamp}</span>
                <span className={styles.user}>{entry.user}</span>
                <span className={styles.action}>{entry.action}</span>
                <span className={styles.details}>{entry.details}</span>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
};
