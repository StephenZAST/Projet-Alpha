import React from 'react';
import { MetricCard } from '../../../components/MetricCard';
import { MetricChart } from '../../../components/MetricChart';
import styles from './styles/GlobalStats.module.css';
import { ChartData } from '../../../types/metrics';

export const GlobalStats: React.FC = () => {
  const performanceMetrics = [
    {
      title: "System Performance",
      value: "98.5%",
      change: { value: "+2.1%", type: 'increase' as const, baseline: "vs last month" }
    },
    {
      title: "User Engagement",
      value: "76.3%",
      change: { value: "+5.4%", type: 'increase' as const, baseline: "vs last month" }
    },
    {
      title: "Service Usage",
      value: "12,456",
      change: { value: "+15%", type: 'increase' as const, baseline: "vs last month" }
    },
    {
      title: "Geographic Coverage",
      value: "28 Regions",
      change: { value: "+3", type: 'increase' as const, baseline: "nouvelles régions" }
    }
  ];

  const engagementData: ChartData[] = [
    { name: 'Jan', value: 4000, date: '2023-01-01' },
    { name: 'Feb', value: 3000, date: '2023-02-01' },
    // ... autres données
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
            data={engagementData}
            color="#0045CE"
          />
        </div>
        <div className={styles.chartCard}>
          <h3>Distribution Géographique</h3>
          <MetricChart
            data={engagementData}
            color="#00AC4F"
          />
        </div>
      </section>

      <section className={styles.reportSection}>
        <div className={styles.reportGenerator}>
          <h3>Générateur de Rapports Personnalisés</h3>
          {/* Composant de génération de rapports à implémenter */}
        </div>
      </section>
    </div>
  );
};
