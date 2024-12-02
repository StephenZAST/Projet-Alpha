import React from 'react';
import { MetricCard } from '../../components/MetricCard';
import { MetricChart } from '../../components/MetricChart';
import styles from '../styles/SystemConfig.module.css';

export const SystemConfig: React.FC = () => {
  const systemMetrics = [
    {
      title: "System Uptime",
      value: "99.9%",
      change: { value: "+0.1%", type: 'increase' as const, baseline: "vs last month" }
    },
    {
      title: "API Performance",
      value: "45ms",
      change: { value: "-5ms", type: 'decrease' as const, baseline: "response time" }
    },
    {
      title: "Active Services",
      value: "28/28",
      change: { value: "100%", type: 'neutral' as const, baseline: "operational" }
    }
  ];

  const mockSystemLogs = [
    { name: '00:00', value: 100, date: '2023-11-28' },
    { name: '02:00', value: 120, date: '2023-11-28' },
    { name: '04:00', value: 95, date: '2023-11-28' },
    { name: '06:00', value: 130, date: '2023-11-28' },
    { name: '08:00', value: 180, date: '2023-11-28' },
    { name: '10:00', value: 220, date: '2023-11-28' },
    { name: '12:00', value: 170, date: '2023-11-28' },
    { name: '14:00', value: 160, date: '2023-11-28' },
    { name: '16:00', value: 190, date: '2023-11-28' },
    { name: '18:00', value: 210, date: '2023-11-28' },
    { name: '20:00', value: 150, date: '2023-11-28' },
    { name: '22:00', value: 110, date: '2023-11-28' }
  ];

  const mockServices = [
    {
      id: 1,
      name: "Authentication Service",
      status: "Operational",
      uptime: "99.99%",
      lastIncident: "None"
    },
    {
      id: 2,
      name: "Payment Processing",
      status: "Operational",
      uptime: "99.95%",
      lastIncident: "2023-11-25"
    },
    {
      id: 3,
      name: "Email Service",
      status: "Degraded",
      uptime: "98.5%",
      lastIncident: "2023-11-28"
    },
    {
      id: 4,
      name: "Storage Service",
      status: "Operational",
      uptime: "99.99%",
      lastIncident: "None"
    },
    {
      id: 5,
      name: "Analytics Engine",
      status: "Operational",
      uptime: "99.90%",
      lastIncident: "2023-11-26"
    }
  ];

  const mockMaintenanceTools = [
    {
      id: 1,
      name: "Backup System",
      description: "Create system backup",
      lastRun: "2023-11-27 23:00",
      status: "Success"
    },
    {
      id: 2,
      name: "Clear Cache",
      description: "Clear system cache",
      lastRun: "2023-11-28 03:00",
      status: "Success"
    },
    {
      id: 3,
      name: "Update System",
      description: "Check and install updates",
      lastRun: "2023-11-25 01:00",
      status: "Success"
    },
    {
      id: 4,
      name: "Security Scan",
      description: "Run security analysis",
      lastRun: "2023-11-28 02:00",
      status: "In Progress"
    }
  ];

  return (
    <div className={styles.systemConfigContainer}>
      <section className={styles.metricsGrid}>
        {systemMetrics.map((metric, index) => (
          <MetricCard
            key={index}
            title={metric.title}
            value={metric.value}
            change={{
              ...metric.change,
              type:
                metric.change.type === 'increase'
                  ? 'positive'
                  : metric.change.type === 'decrease'
                  ? 'negative'
                  : 'neutral',
            }}
          />
        ))}
      </section>

      <section className={styles.configPanels}>
        <div className={styles.configCard}>
          <h3>Status des Services</h3>
          <div className={styles.servicesList}>
            {mockServices.map((service) => (
              <div key={service.id} className={styles.serviceItem}>
                <div className={styles.serviceName}>{service.name}</div>
                <div className={`${styles.serviceStatus} ${styles[service.status.toLowerCase()]}`}>
                  {service.status}
                </div>
                <div className={styles.serviceUptime}>
                  <span>Uptime:</span> {service.uptime}
                </div>
                <div className={styles.serviceIncident}>
                  <span>Dernier incident:</span> {service.lastIncident}
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className={styles.configCard}>
          <h3>Moniteur API</h3>
          <MetricChart
            data={mockSystemLogs}
            color="#0045CE"
          />
        </div>
      </section>

      <section className={styles.maintenanceTools}>
        <div className={styles.toolCard}>
          <h3>Outils de Maintenance</h3>
          <div className={styles.toolGrid}>
            {mockMaintenanceTools.map((tool) => (
              <div key={tool.id} className={styles.toolItem}>
                <button className={`${styles.toolButton} ${styles[tool.status.toLowerCase()]}`}>
                  {tool.name}
                </button>
                <div className={styles.toolInfo}>
                  <p>{tool.description}</p>
                  <span>Dernière exécution: {tool.lastRun}</span>
                  <span className={styles[tool.status.toLowerCase()]}>
                    Status: {tool.status}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
};
