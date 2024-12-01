import React from 'react';
import styles from '../styles/Settings.module.css';
import { MetricCard } from '../../../components/MetricCard';
import { Table } from '../../../components/Table';

export const AffilietesSettings: React.FC = () => {
  const mockUser = {
    email: 'admin@example.com',
    phone: '+33 123 456 789',
    name: 'Jean Dupont',
    role: 'Master Super Admin'
  };

  const affiliateMetrics = [
    {
      title: "Total Affiliates",
      value: "156",
      change: { value: "+8", type: 'increase' as const, baseline: "ce mois" }
    },
    {
      title: "Active Affiliates",
      value: "134",
      change: { value: "+12", type: 'increase' as const, baseline: "cette semaine" }
    },
    {
      title: "Revenue Generated",
      value: "€89,450",
      change: { value: "+15%", type: 'increase' as const, baseline: "vs dernier mois" }
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

  const mockAffiliateData = [
    {
      id: 1,
      companyName: "Tech Solutions SA",
      contactPerson: "Marie Lambert",
      email: "marie@techsolutions.com",
      phone: "+33 123 456 789",
      status: "Active",
      revenue: "€23,450",
      actions: "Edit | Delete"
    },
    {
      id: 2,
      companyName: "Digital Services SARL",
      contactPerson: "Pierre Martin",
      email: "pierre@digitalservices.com",
      phone: "+33 234 567 890",
      status: "Active",
      revenue: "€18,670",
      actions: "Edit | Delete"
    },
    {
      id: 3,
      companyName: "Web Experts SAS",
      contactPerson: "Sophie Bernard",
      email: "sophie@webexperts.com",
      phone: "+33 345 678 901",
      status: "Inactive",
      revenue: "€12,890",
      actions: "Edit | Delete"
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
          headers={affiliateTableHeaders}
          data={mockAffiliateData}
          onSearch={(value) => console.log('Search:', value)}
          onSort={(field) => console.log('Sort by:', field)}
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