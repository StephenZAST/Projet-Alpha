import React from 'react';
import { MetricCard } from '../../../../components/MetricCard';
import { Table } from '../../../../components/Table';
import { MetricChart } from '../../../../components/MetricChart';
import styles from './SystemConfig.module.css';

export const SystemConfig: React.FC = () => {
  const systemMetrics = [
    {
      title: "System Uptime",
      value: "99.9%",
      change: { value: "+0.1%", type: "increase", baseline: "vs last month" }
    },
    {
      title: "API Performance",
      value: "45ms",
      change: { value: "-5ms", type: "increase", baseline: "response time" }
    },
    {
      title: "Active Services",
      value: "28/28",
      change: { value: "100%", type: "neutral", baseline: "operational" }
    }
  ];

  const systemLogs = [
    { name: 'Jan', value: 100 },
    { name: 'Feb', value: 120 },
    // ... autres données
  ];

  return (
    <div className={styles.systemConfigContainer}>
      <section className={styles.metricsGrid}>
        {systemMetrics.map((metric, index) => (
          <MetricCard key={index} {...metric} />
        ))}
      </section>

      <section className={styles.configPanels}>
        <div className={styles.configCard}>
          <h3>Status des Services</h3>
          <div className={styles.servicesList}>
            {/* Liste des services avec leur statut */}
          </div>
        </div>

        <div className={styles.configCard}>
          <h3>Moniteur API</h3>
          <MetricChart
            data={systemLogs}
            type="area"
            color="#0045CE"
          />
        </div>
      </section>

      <section className={styles.maintenanceTools}>
        <div className={styles.toolCard}>
          <h3>Outils de Maintenance</h3>
          <div className={styles.toolGrid}>
            <button className={styles.toolButton}>Backup System</button>
            <button className={styles.toolButton}>Clear Cache</button>
            <button className={styles.toolButton}>Update System</button>
            <button className={styles.toolButton}>Security Scan</button>
          </div>
        </div>
      </section>
    </div>
  );
};
