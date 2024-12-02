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

const AdminManagement: React.FC = () => {
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);

  const adminStats = [
    {
      title: "Total Admins",
      value: mockMasterAdminData.adminManagement.totalAdmins.toString(),
      icon: "admin_panel_settings",
      trend: {
        value: "8%",
        direction: "up" as const,
        text: "vs last month"
      }
    },
    {
      title: "Active Admins",
      value: mockMasterAdminData.adminManagement.activeAdmins.toString(),
      icon: "verified_user",
      trend: {
        value: "12%",
        direction: "up" as const,
        text: "vs last month"
      }
    },
    {
      title: "Pending Actions",
      value: "5",
      icon: "pending_actions"
    }
  ];

  const mockAdmins: Admin[] = [
    {
      id: 1,
      name: "Jean Dupont",
      role: "Super Admin",
      company: "TechCorp",
      lastActive: "2024-01-15 14:30",
      status: "active",
      email: "jean.dupont@techcorp.com"
    },
    {
      id: 2,
      name: "Marie Martin",
      role: "Admin",
      company: "DataSys",
      lastActive: "2024-01-15 12:45",
      status: "active",
      email: "marie.martin@datasys.com"
    }
  ];

  return (
    <div className={styles.adminManagement}>
      <div className={styles.header}>
        <h1>Gestion des Administrateurs</h1>
        <button 
          className={styles.addButton}
          onClick={() => setIsAddModalOpen(true)}
        >
          <span className="material-icons">add</span>
          Nouvel Admin
        </button>
      </div>

      <div className={styles.statsGrid}>
        {adminStats.map((stat, index) => (
          <StatCard
            key={index}
            {...stat}
          />
        ))}
      </div>

      <div className={styles.adminList}>
        <div className={styles.listHeader}>
          <h2>Liste des Administrateurs</h2>
          <div className={styles.filters}>
            <input
              type="text"
              placeholder="Rechercher..."
              className={styles.searchInput}
            />
            <select className={styles.filterSelect}>
              <option value="all">Tous les statuts</option>
              <option value="active">Actif</option>
              <option value="inactive">Inactif</option>
            </select>
          </div>
        </div>

        <table className={styles.table}>
          <thead>
            <tr>
              <th>Nom</th>
              <th>Rôle</th>
              <th>Entreprise</th>
              <th>Dernière activité</th>
              <th>Statut</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {mockAdmins.map(admin => (
              <tr key={admin.id}>
                <td>
                  <div className={styles.adminInfo}>
                    <span className={styles.adminName}>{admin.name}</span>
                    <span className={styles.adminEmail}>{admin.email}</span>
                  </div>
                </td>
                <td>{admin.role}</td>
                <td>{admin.company}</td>
                <td>{admin.lastActive}</td>
                <td>
                  <span className={`${styles.status} ${styles[admin.status]}`}>
                    {admin.status}
                  </span>
                </td>
                <td>
                  <div className={styles.actions}>
                    <button className={styles.actionButton}>
                      <span className="material-icons">edit</span>
                    </button>
                    <button className={styles.actionButton}>
                      <span className="material-icons">delete</span>
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {isAddModalOpen && (
        <div className={styles.modal}>
          {/* Modal content */}
        </div>
      )}
    </div>
  );
};

export default AdminManagement;
