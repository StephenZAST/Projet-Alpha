import React, { useState } from 'react';
import { StatCard } from '../../components/common/StatCard/StatCard';
import { mockMasterAdminData } from '../../services/mockData';
import styles from './AdminManagement.module.css';

interface Admin {
  id: number;
  name: string;
  role: string;
  company: string;
  lastActive: string;
  status: 'active' | 'inactive';
  email: string;
}

export const AdminManagement: React.FC = () => {
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);

  const adminStats = [
    {
      title: "Total Admins",
      value: mockMasterAdminData.adminManagement.totalAdmins.toString(),
      icon: "/icons/admin-total.svg",
      trend: {
        value: "8%",
        direction: "up",
        text: "vs last month"
      }
    },
    {
      title: "Active Admins",
      value: mockMasterAdminData.adminManagement.activeAdmins.toString(),
      icon: "/icons/admin-active.svg",
      trend: {
        value: "12%",
        direction: "up",
        text: "vs last month"
      }
    },
    {
      title: "Pending Actions",
      value: "5",
      icon: "/icons/admin-pending.svg"
    }
  ];

  const mockAdmins: Admin[] = [
    {
      id: 1,
      name: "Jean Dupont",
      role: "Super Admin",
      company: "Headquarters",
      lastActive: "2024-01-15 14:30",
      status: "active",
      email: "jean.dupont@company.com"
    },
    {
      id: 2,
      name: "Marie Lambert",
      role: "Regional Admin",
      company: "Europe Division",
      lastActive: "2024-01-15 12:15",
      status: "active",
      email: "marie.lambert@company.com"
    },
    {
      id: 3,
      name: "Pierre Martin",
      role: "Local Admin",
      company: "Paris Branch",
      lastActive: "2024-01-14 16:45",
      status: "inactive",
      email: "pierre.martin@company.com"
    }
  ];

  return (
    <div className={styles.adminManagement}>
      <div className={styles.header}>
        <h1 className={styles.title}>Admin Management</h1>
        <button
          className={styles.addButton}
          onClick={() => setIsAddModalOpen(true)}
        >
          <span className="material-icons">add</span>
          Add New Admin
        </button>
      </div>

      <div className={styles.statsGrid}>
        {adminStats.map((stat, index) => (
          <StatCard
            key={index}
            title={stat.title}
            value={stat.value}
            icon={stat.icon}
            trend={stat.trend as { value: string; direction: "up" | "down"; text?: string }}
          />
        ))}
      </div>

      <div className={styles.mainContent}>
        <div className={styles.adminList}>
          <div className={styles.listHeader}>
            <div className={styles.searchBar}>
              <span className="material-icons">search</span>
              <input
                type="text"
                placeholder="Search admins..."
                className={styles.searchInput}
              />
            </div>
            <div className={styles.filters}>
              <select className={styles.filterSelect}>
                <option value="all">All Roles</option>
                <option value="super">Super Admin</option>
                <option value="regional">Regional Admin</option>
                <option value="local">Local Admin</option>
              </select>
              <select className={styles.filterSelect}>
                <option value="all">All Status</option>
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
              </select>
            </div>
          </div>

          <div className={styles.table}>
            <div className={styles.tableHeader}>
              <div className={styles.tableCell}>Name</div>
              <div className={styles.tableCell}>Role</div>
              <div className={styles.tableCell}>Company</div>
              <div className={styles.tableCell}>Last Active</div>
              <div className={styles.tableCell}>Status</div>
              <div className={styles.tableCell}>Actions</div>
            </div>
            
            {mockAdmins.map((admin) => (
              <div key={admin.id} className={styles.tableRow}>
                <div className={styles.tableCell}>
                  <div className={styles.adminInfo}>
                    <div className={styles.avatar}>
                      {admin.name.charAt(0)}
                    </div>
                    <div className={styles.adminDetails}>
                      <span className={styles.adminName}>{admin.name}</span>
                      <span className={styles.adminEmail}>{admin.email}</span>
                    </div>
                  </div>
                </div>
                <div className={styles.tableCell}>{admin.role}</div>
                <div className={styles.tableCell}>{admin.company}</div>
                <div className={styles.tableCell}>{admin.lastActive}</div>
                <div className={styles.tableCell}>
                  <span className={`${styles.status} ${styles[admin.status]}`}>
                    {admin.status}
                  </span>
                </div>
                <div className={styles.tableCell}>
                  <div className={styles.actions}>
                    <button className={styles.actionButton}>
                      <span className="material-icons">edit</span>
                    </button>
                    <button className={styles.actionButton}>
                      <span className="material-icons">delete</span>
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className={styles.recentActivity}>
          <h2 className={styles.sectionTitle}>Recent Activities</h2>
          <div className={styles.activityList}>
            {mockMasterAdminData.adminManagement.recentActions.map((action) => (
              <div key={action.id} className={styles.activityItem}>
                <div className={styles.activityIcon}>
                  <span className="material-icons">history</span>
                </div>
                <div className={styles.activityContent}>
                  <p className={styles.activityText}>
                    <span className={styles.activityAdmin}>{action.admin}</span>
                    {action.action}
                  </p>
                  <span className={styles.activityTime}>
                    {new Date(action.timestamp).toLocaleTimeString()}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Add Admin Modal */}
      {isAddModalOpen && (
        <div className={styles.modal}>
          <div className={styles.modalContent}>
            <div className={styles.modalHeader}>
              <h2>Add New Admin</h2>
              <button
                className={styles.closeButton}
                onClick={() => setIsAddModalOpen(false)}
              >
                <span className="material-icons">close</span>
              </button>
            </div>
            <form className={styles.modalForm}>
              <div className={styles.formGroup}>
                <label>Name</label>
                <input type="text" placeholder="Enter admin name" />
              </div>
              <div className={styles.formGroup}>
                <label>Email</label>
                <input type="email" placeholder="Enter admin email" />
              </div>
              <div className={styles.formGroup}>
                <label>Role</label>
                <select>
                  <option value="">Select role</option>
                  <option value="super">Super Admin</option>
                  <option value="regional">Regional Admin</option>
                  <option value="local">Local Admin</option>
                </select>
              </div>
              <div className={styles.formGroup}>
                <label>Company</label>
                <input type="text" placeholder="Enter company name" />
              </div>
              <div className={styles.modalActions}>
                <button
                  type="button"
                  className={styles.cancelButton}
                  onClick={() => setIsAddModalOpen(false)}
                >
                  Cancel
                </button>
                <button type="submit" className={styles.submitButton}>
                  Add Admin
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
