import React from 'react';
import { MetricCard } from '../../../../components/MetricCard';
import { MetricChart } from '../../../../components/MetricChart';
import { Table } from '../../../../components/Table';
import styles from './GlobalFinance.module.css';

export const GlobalFinance: React.FC = () => {
  const financialMetrics = [
    {
      title: "Total Revenue",
      value: "125M FCFA",
      change: { value: "+23%", type: "increase", baseline: "vs last month" }
    },
    {
      title: "Monthly Growth",
      value: "15.4%",
      change: { value: "+2.1%", type: "increase", baseline: "vs last month" }
    },
    {
      title: "Pending Payments",
      value: "2.3M FCFA",
      change: { value: "-5%", type: "decrease", baseline: "vs last month" }
    },
    {
      title: "Outstanding Invoices",
      value: "4.7M FCFA",
      change: { value: "+12%", type: "increase", baseline: "vs last month" }
    }
  ];

  const transactionHeaders = [
    "Transaction ID",
    "Company",
    "Amount",
    "Date",
    "Status",
    "Type"
  ];

  const revenueData = [
    { name: 'Jan', value: 4000000 },
    { name: 'Feb', value: 3000000 },
    // ... autres données
  ];

  return (
    <div className={styles.financeContainer}>
      <section className={styles.metricsGrid}>
        {financialMetrics.map((metric, index) => (
          <MetricCard key={index} {...metric} />
        ))}
      </section>

      <section className={styles.chartsSection}>
        <div className={styles.chartCard}>
          <h3>Tendance des Revenus</h3>
          <MetricChart
            data={revenueData}
            type="area"
            color="#0045CE"
          />
        </div>
        <div className={styles.chartCard}>
          <h3>Distribution des Revenus</h3>
          <MetricChart
            data={revenueData}
            type="area"
            color="#00AC4F"
          />
        </div>
      </section>

      <section className={styles.transactionsSection}>
        <Table
          headers={transactionHeaders}
          data={[]} // Will be populated with real data
          onSearch={(value) => console.log('Search:', value)}
          onSort={(field) => console.log('Sort by:', field)}
          title="Historique des Transactions"
        />
      </section>
    </div>
  );
};
