import React from 'react';
import { TableRowProps } from '../types';
import styles from './style/CustomerTable.module.css';
import Table from './Table'; 

const tableData: TableRowProps[] = [
  {
    customerName: "Jane Cooper",
    company: "Microsoft",
    phoneNumber: "(225) 555-0118",
    email: "jane@microsoft.com",
    country: "United States",
    status: "active"
  },
  // ... other rows as per the original data
];

export const CustomerTable: React.FC = () => {
  const columns = [
    { key: 'customerName', label: 'Customer Name' },
    { key: 'company', label: 'Company' },
    { key: 'phoneNumber', label: 'Phone Number' },
    { key: 'email', label: 'Email' },
    { key: 'country', label: 'Country' },
    {
      key: 'status',
      label: 'Status',
      render: (item: TableRowProps) => (
        <span className={`${styles.status} ${styles[item.status]}`}>
          {item.status}
        </span>
      )
    },
  ];

  return (
    <section className={styles.tableContainer}>
      <header className={styles.tableHeader}>
        <h2 className={styles.title}>All Customers</h2>
        <div className={styles.controls}>
          <select className={styles.sortSelect} defaultValue="newest">
            <option value="newest">Newest</option>
            <option value="oldest">Oldest</option>
          </select>
        </div>
      </header>
      
      <div className={styles.tableWrapper}>
        <Table data={tableData} columns={columns} /> {/* Use the Table component */}
      </div>
    </section>
  );
};
