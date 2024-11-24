import React from 'react';
import { TableRowProps } from '../types';
import styles from './style/CustomerTable.module.css';

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
        <table className={styles.table}>
          <thead>
            <tr>
              <th>Customer Name</th>
              <th>Company</th>
              <th>Phone Number</th>
              <th>Email</th>
              <th>Country</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {tableData.map((row, index) => (
              <tr key={index}>
                <td>{row.customerName}</td>
                <td>{row.company}</td>
                <td>{row.phoneNumber}</td>
                <td>{row.email}</td>
                <td>{row.country}</td>
                <td>
                  <span className={`${styles.status} ${styles[row.status]}`}>
                    {row.status}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </section>
  );
};