import React, { useState } from 'react';
import { StatCard } from '../../components/common/StatCard/StatCard';
import styles from './Company.module.css';

interface Company {
  id: number;
  name: string;
  industry: string;
  employees: number;
  status: 'active' | 'inactive';
  subscription: string;
  lastBilling: string;
}

const Company: React.FC = () => {
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);

  const companyStats = [
    {
      title: "Total Companies",
      value: "156",
      icon: "business",
      trend: {
        value: "12%",
        direction: "up" as const,
        text: "vs last month"
      }
    },
    {
      title: "Active Subscriptions",
      value: "142",
      icon: "verified",
      trend: {
        value: "8%",
        direction: "up" as const,
        text: "vs last month"
      }
    },
    {
      title: "Pending Approvals",
      value: "7",
      icon: "pending"
    }
  ];

  const mockCompanies: Company[] = [
    {
      id: 1,
      name: "TechCorp Solutions",
      industry: "Technology",
      employees: 250,
      status: "active",
      subscription: "Enterprise",
      lastBilling: "2024-01-15"
    },
    {
      id: 2,
      name: "DataSys International",
      industry: "Data Analytics",
      employees: 120,
      status: "active",
      subscription: "Professional",
      lastBilling: "2024-01-14"
    }
  ];

  return (
    <div className={styles.companyManagement}>
      <div className={styles.header}>
        <h1>Gestion des Entreprises</h1>
        <button 
          className={styles.addButton}
          onClick={() => setIsAddModalOpen(true)}
        >
          <span className="material-icons">add</span>
          Nouvelle Entreprise
        </button>
      </div>

      <div className={styles.statsGrid}>
        {companyStats.map((stat, index) => (
          <StatCard
            key={index}
            {...stat}
          />
        ))}
      </div>

      <div className={styles.companyList}>
        <div className={styles.listHeader}>
          <h2>Liste des Entreprises</h2>
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
              <th>Entreprise</th>
              <th>Industrie</th>
              <th>Employés</th>
              <th>Statut</th>
              <th>Abonnement</th>
              <th>Dernière Facturation</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {mockCompanies.map(company => (
              <tr key={company.id}>
                <td>
                  <div className={styles.companyInfo}>
                    <span className={styles.companyName}>{company.name}</span>
                  </div>
                </td>
                <td>{company.industry}</td>
                <td>{company.employees}</td>
                <td>
                  <span className={`${styles.status} ${styles[company.status]}`}>
                    {company.status}
                  </span>
                </td>
                <td>{company.subscription}</td>
                <td>{company.lastBilling}</td>
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

export default Company;
