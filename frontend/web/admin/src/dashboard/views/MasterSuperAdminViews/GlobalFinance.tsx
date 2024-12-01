import React from 'react';
import { MetricCard } from '../../../components/MetricCard';
import { MetricChart } from '../../../components/MetricChart';
import { Table } from '../../../components/Table';
import styles from '../styles/GlobalFinance.module.css';

export const GlobalFinance: React.FC = () => {
  const financialMetrics = [
    {
      title: "Total Revenue",
      value: "125M FCFA",
      change: { value: "+23%", type: 'increase' as const , baseline: "vs last month" }
    },
    {
      title: "Monthly Growth",
      value: "15.4%",
      change: { value: "+2.1%", type: 'increase' as const , baseline: "vs last month" }
    },
    {
      title: "Pending Payments",
      value: "2.3M FCFA",
      change: { value: "-5%", type: 'decrease' as const, baseline: "vs last month" }
    },
    {
      title: "Outstanding Invoices",
      value: "4.7M FCFA",
      change: { value: "+12%", type: 'increase' as const, baseline: "vs last month" }
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

  const mockTransactions = [
    {
      id: "TRX-001",
      company: "Tech Solutions SA",
      amount: "2.5M FCFA",
      date: "2023-11-28",
      status: "Completed",
      type: "Payment"
    },
    {
      id: "TRX-002",
      company: "Digital Services SARL",
      amount: "1.8M FCFA",
      date: "2023-11-27",
      status: "Pending",
      type: "Invoice"
    },
    {
      id: "TRX-003",
      company: "Web Experts SAS",
      amount: "3.2M FCFA",
      date: "2023-11-26",
      status: "Completed",
      type: "Payment"
    },
    {
      id: "TRX-004",
      company: "Marketing Pro SARL",
      amount: "950K FCFA",
      date: "2023-11-25",
      status: "Failed",
      type: "Payment"
    }
  ];

  const mockRevenueData = [
    { name: 'Jan', value: 4000000, date: '2023-01-01' },
    { name: 'Feb', value: 3000000, date: '2023-02-01' },
    { name: 'Mar', value: 4500000, date: '2023-03-01' },
    { name: 'Apr', value: 3800000, date: '2023-04-01' },
    { name: 'May', value: 5200000, date: '2023-05-01' },
    { name: 'Jun', value: 4800000, date: '2023-06-01' },
    { name: 'Jul', value: 6000000, date: '2023-07-01' },
    { name: 'Aug', value: 5500000, date: '2023-08-01' },
    { name: 'Sep', value: 6500000, date: '2023-09-01' },
    { name: 'Oct', value: 7200000, date: '2023-10-01' },
    { name: 'Nov', value: 6800000, date: '2023-11-01' }
  ];

  const mockRevenueDistribution = [
    { name: 'Subscriptions', value: 45, date: '2023-11-01' },
    { name: 'Services', value: 30, date: '2023-11-01' },
    { name: 'Products', value: 15, date: '2023-11-01' },
    { name: 'Other', value: 10, date: '2023-11-01' }
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
            data={mockRevenueData}
            color="#0045CE"
          />
        </div>
        <div className={styles.chartCard}>
          <h3>Distribution des Revenus</h3>
          <MetricChart
            data={mockRevenueDistribution}
            color="#00AC4F"
          />
        </div>
      </section>

      <section className={styles.transactionsSection}>
        <Table
          headers={transactionHeaders}
          data={mockTransactions}
          onSearch={(value) => console.log('Search:', value)}
          onSort={(field) => console.log('Sort by:', field)}
          title="Historique des Transactions"
        />
      </section>
    </div>
  );
};