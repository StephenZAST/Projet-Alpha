import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { AppDispatch, RootState } from '../../../redux/store';
import { MetricCard } from '../../../components/MetricCard';
import { Table } from '../../../components/Table';
import { MetricChart } from '../../../components/MetricChart';
import { fetchDashboardMetrics } from '../../../redux/slices/dashboardSlice';
import styles from './styles/Overview.module.css';
import { DashboardMetrics, ChartData } from '../../../types/metrics';

export const Overview: React.FC = () => {
  const dispatch = useDispatch<AppDispatch>();
  const metrics = useSelector((state: RootState) => state.dashboard) as unknown as DashboardMetrics;

  useEffect(() => {
    dispatch(fetchDashboardMetrics());
  }, [dispatch]);

  const topMetrics = [
    {
      title: "Total Customers",
      value: metrics.totalCustomers ? metrics.totalCustomers.toString() : "5,423",
      change: { value: "+12%", type: 'increase' as const, baseline: "vs last month" }
    },
    {
      title: "Active Members",
      value: metrics.activeMembers ? metrics.activeMembers.toString() : "1,893",
      change: { value: "+8%", type: 'increase' as const, baseline: "vs last month" }
    },
    // ... autres métriques
  ];

  const tableHeaders = ["Customer Name", "Company", "Phone Number", "Email", "Country", "Status"];
  const chartData: ChartData[] = [/* données pour le graphique */];

  return (
    <div className={styles.overviewContainer}>
      <section className={styles.topMetrics}>
        {topMetrics.map((metric, index) => (
          <MetricCard key={index} {...metric} />
        ))}
      </section>

      <section className={styles.chartsSection}>
        <MetricChart
          data={chartData}
          color="#0045CE"
        />
      </section>

      <section className={styles.tableSection}>
        <Table
          headers={tableHeaders}
          data={metrics.customers || []}
          onSearch={(value) => console.log('Search:', value)}
          onSort={(field) => console.log('Sort by:', field)}
          title="All Customers"
        />
      </section>
    </div>
  );
};
