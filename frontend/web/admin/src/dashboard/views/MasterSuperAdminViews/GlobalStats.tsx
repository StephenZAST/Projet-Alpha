import React from 'react';
import { MetricCard } from '../../components/MetricCard';
import { MetricChart } from '../../components/MetricChart';
import styles from './styles/GlobalStats.module.css';

export const GlobalStats: React.FC = () => {
  const performanceMetrics = [
    {
      title: "System Performance",
      value: "98.5%",
      change: { value: "+2.1%", type: 'positive' as const, baseline: "vs last month" }
    },
    {
      title: "User Engagement",
      value: "76.3%",
      change: { value: "+5.4%", type: 'positive' as const, baseline: "vs last month" }
    },
    {
      title: "Service Usage",
      value: "12,456",
      change: { value: "+15%", type: 'positive' as const, baseline: "vs last month" }
    },
    {
      title: "Geographic Coverage",
      value: "28 Regions",
      change: { value: "+3", type: 'positive' as const, baseline: "nouvelles régions" }
    }
  ];

  const mockEngagementData = [
    { name: 'Jan', value: 4000, date: '2023-01-01' },
    { name: 'Feb', value: 3000, date: '2023-02-01' },
    { name: 'Mar', value: 5000, date: '2023-03-01' },
    { name: 'Apr', value: 4500, date: '2023-04-01' },
    { name: 'May', value: 6000, date: '2023-05-01' },
    { name: 'Jun', value: 5500, date: '2023-06-01' },
    { name: 'Jul', value: 7000, date: '2023-07-01' },
    { name: 'Aug', value: 6500, date: '2023-08-01' },
    { name: 'Sep', value: 8000, date: '2023-09-01' },
    { name: 'Oct', value: 7500, date: '2023-10-01' },
    { name: 'Nov', value: 9000, date: '2023-11-01' }
  ];

  const mockGeographicData = [
    { name: 'Dakar', value: 35, date: '2023-11-01' },
    { name: 'Thiès', value: 20, date: '2023-11-01' },
    { name: 'Saint-Louis', value: 15, date: '2023-11-01' },
    { name: 'Kaolack', value: 10, date: '2023-11-01' },
    { name: 'Ziguinchor', value: 8, date: '2023-11-01' },
    { name: 'Others', value: 12, date: '2023-11-01' }
  ];

  const mockReportTemplates = [
    {
      id: 1,
      name: "Performance Mensuelle",
      description: "Rapport détaillé des performances système",
      lastGenerated: "2023-11-28"
    },
    {
      id: 2,
      name: "Engagement Utilisateurs",
      description: "Analyse de l'engagement utilisateur par région",
      lastGenerated: "2023-11-27"
    },
    {
      id: 3,
      name: "Couverture Géographique",
      description: "Distribution des services par région",
      lastGenerated: "2023-11-26"
    }
  ];

  return (
    <div className={styles.globalStatsContainer}>
      <section className={styles.metricsGrid}>
        {performanceMetrics.map((metric, index) => (
          <MetricCard key={index} {...metric} />
        ))}
      </section>

      <section className={styles.analyticsSection}>
        <div className={styles.chartCard}>
          <h3>Engagement Utilisateurs</h3>
          <MetricChart
            data={mockEngagementData}
            color="#0045CE"
          />
        </div>
        <div className={styles.chartCard}>
          <h3>Distribution Géographique</h3>
          <MetricChart
            data={mockGeographicData}
            color="#00AC4F"
          />
        </div>
      </section>

      <section className={styles.reportSection}>
        <div className={styles.reportGenerator}>
          <h3>Générateur de Rapports Personnalisés</h3>
          <div className={styles.reportTemplates}>
            {mockReportTemplates.map((template) => (
              <div key={template.id} className={styles.reportTemplate}>
                <h4>{template.name}</h4>
                <p>{template.description}</p>
                <span>Dernier rapport: {template.lastGenerated}</span>
                <button className={styles.generateButton}>
                  Générer Rapport
                </button>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
};
