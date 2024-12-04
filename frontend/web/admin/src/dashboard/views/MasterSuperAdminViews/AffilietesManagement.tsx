import React from 'react';
import styles from '../styles/Settings.module.css';
import { MetricCard } from '../../components/MetricCard';
import { Table } from '../../components/Table';
import { Customer, MetricCardProps } from '../../types';

export const AffilietesManagement: React.FC = () => {
  const mockUser = {
    email: 'admin@example.com',
    phone: '+33 123 456 789',
    name: 'Jean Dupont',
    role: 'Master Super Admin'
  };

  const affiliateMetrics: MetricCardProps[] = [
    {
      title: "Total Affiliates",
      value: "156",
      change: { value: "+8", type: 'positive', baseline: "ce mois" }
    },
    {
      title: "Active Affiliates",
      value: "134",
      change: { value: "+12", type: 'positive', baseline: "cette semaine" }
    },
    {
      title: "Revenue Generated",
      value: "€89,450",
      change: { value: "+15%", type: 'positive', baseline: "vs dernier mois" }
    }
  ];

  const affiliateTableHeaders = [
    "Company Name",
    "Contact Person",
    "Email",
    "Phone",
    "Status",
    "Revenue",
    "Actions"
  ];

  const mockAffiliateData: Customer[] = [
    {
      name: "Tech Solutions SA",
      company: "Tech Solutions SA",
      phone: "+33 123 456 789",
      email: "marie@techsolutions.com",
      country: "France",
      status: "active"
    },
    {
      name: "Digital Services SARL",
      company: "Digital Services SARL",
      phone: "+33 234 567 890",
      email: "pierre@digitalservices.com",
      country: "France",
      status: "active"
    },
    {
      name: "Web Experts SAS",
      company: "Web Experts SAS",
      phone: "+33 345 678 901",
      email: "sophie@webexperts.com",
      country: "France",
      status: "inactive"
    }
  ];

  return (
    <div className={styles.settingsContainer}>
      <section className={styles.metricsSection}>
        {affiliateMetrics.map((metric, index) => (
          <MetricCard key={index} {...metric} />
        ))}
      </section>

      <section className={styles.mainContent}>
        <Table
          customers={mockAffiliateData}
          headers={affiliateTableHeaders}
          onSearch={(value: string) => console.log('Search:', value)}
          onSort={(field: string) => console.log('Sort by:', field)}
          title="Gestion des Affiliés"
        />
      </section>

      <section className={styles.profileSection}>
        <div className={styles.profileCard}>
          <h3>Informations Personnelles</h3>
          <div className={styles.profileForm}>
            <div className={styles.formGroup}>
              <label>Email</label>
              <input type="email" defaultValue={mockUser.email} />
            </div>
            <div className={styles.formGroup}>
              <label>Téléphone</label>
              <input type="tel" defaultValue={mockUser.phone} />
            </div>
            <div className={styles.formGroup}>
              <label>Nom</label>
              <input type="text" defaultValue={mockUser.name} disabled />
            </div>
            <div className={styles.formGroup}>
              <label>Type Admin</label>
              <input type="text" defaultValue={mockUser.role} disabled />
            </div>
            <button className={styles.updateButton}>
              Mettre à jour
            </button>
          </div>
        </div>
      </section>

      <section className={styles.preferencesSection}>
        <div className={styles.preferencesCard}>
          <h3>Préférences</h3>
          <div className={styles.preferencesList}>
            <div className={styles.preferenceItem}>
              <label>Notifications Email</label>
              <input type="checkbox" defaultChecked />
            </div>
            <div className={styles.preferenceItem}>
              <label>Notifications SMS</label>
              <input type="checkbox" />
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};
