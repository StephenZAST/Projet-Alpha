import React from 'react';
import { MetricCard } from '../../../components/MetricCard';
import { Table } from '../../../components/Table';
import { MetricChart } from '../../../components/MetricChart';
import styles from '../styles/Overview.module.css';

export const Overview: React.FC = () => {
  const mockTopMetrics = [
    {
      title: "Total Customers",
      value: "5,423",
      change: { value: "+12%", type: 'increase' as const, baseline: "vs last month" }
    },
    {
      title: "Active Members",
      value: "1,893",
      change: { value: "+8%", type: 'increase' as const, baseline: "vs last month" }
    },
    {
      title: "Revenue",
      value: "$842,314",
      change: { value: "+23%", type: 'increase' as const, baseline: "vs last month" }
    },
    {
      title: "Active Projects",
      value: "267",
      change: { value: "-3%", type: 'decrease' as const, baseline: "vs last month" }
    }
  ];

  const mockTableHeaders = ["Customer Name", "Company", "Phone Number", "Email", "Country", "Status"];
  
  const mockTableData = [
    {
      id: 1,
      customerName: "John Smith",
      company: "Tech Corp",
      phoneNumber: "+1 234 567 890",
      email: "john@techcorp.com",
      country: "United States",
      status: "Active"
    },
    {
      id: 2,
      customerName: "Marie Claire",
      company: "Design Studio",
      phoneNumber: "+33 123 456 789",
      email: "marie@designstudio.com",
      country: "France",
      status: "Active"
    },
    {
      id: 3,
      customerName: "Carlos Rodriguez",
      company: "Dev Solutions",
      phoneNumber: "+34 612 345 678",
      email: "carlos@devsolutions.com",
      country: "Spain",
      status: "Inactive"
    },
    {
      id: 4,
      customerName: "Sarah Johnson",
      company: "Creative Labs",
      phoneNumber: "+44 789 123 456",
      email: "sarah@creativelabs.com",
      country: "UK",
      status: "Active"
    }
  ];

  const mockChartData = [
    { name: 'Jan', date: '2023-01', value: 1234 },
    { name: 'Feb', date: '2023-02', value: 2345 },
    { name: 'Mar', date: '2023-03', value: 1856 },
    { name: 'Apr', date: '2023-04', value: 2967 },
    { name: 'May', date: '2023-05', value: 3478 },
    { name: 'Jun', date: '2023-06', value: 2989 },
    { name: 'Jul', date: '2023-07', value: 3590 }
  ];

  return (
    <div className={styles.overviewContainer}>
      <section className={styles.topMetrics}>
        {mockTopMetrics.map((metric, index) => (
          <MetricCard key={index} {...metric} />
        ))}
      </section>

      <section className={styles.chartsSection}>
        <MetricChart
          data={mockChartData}
          color="#0045CE"
        />
      </section>
        
      <section className={styles.tableSection}>
        <Table
          headers={mockTableHeaders}
          data={mockTableData}
          onSearch={(value) => console.log('Search:', value)}
          onSort={(field) => console.log('Sort by:', field)}
          title="All Customers"
        />
      </section>
    </div>
  );
};