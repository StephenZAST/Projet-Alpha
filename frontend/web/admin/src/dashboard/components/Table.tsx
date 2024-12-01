import React from 'react';
import styles from '../styles/CustomerTable.module.css';
import { TableProps } from '../types.ts';
import { Pagination } from './Pagination.tsx';



interface TableProps {
  headers: string[];
  data: any[];
  onSort?: (field: string) => void;
  onSearch?: (value: string) => void;
  title?: string;
}

export const Table: React.FC<TableProps> = ({
  headers,
  data,
  onSort,
  onSearch,
  title = "All Data"
}) => {
  return (
    <section className={styles.tableContainer}>
      <header className={styles.tableHeader}>
        <h2 className={styles.tableTitle}>All Customers</h2>
        <div className={styles.tableActions}>
          <form className={styles.searchForm}>
            <label htmlFor="customerSearch" className="sr-only">
              Search customers
            </label>
            <input
              id="customerSearch"
              type="search"
              placeholder="Search"
              className={styles.searchInput}
            />
          </form>
          <div className={styles.sortDropdown}>
            <span>Sort by: </span>
            <select className={styles.sortSelect}>
              <option value="newest">Newest</option>
              <option value="oldest">Oldest</option>
            </select>
          </div>
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
            {customers.map((customer, index) => (
              <tr key={index}>
                <td>{customer.name}</td>
                <td>{customer.company}</td>
                <td>{customer.phone}</td>
                <td>{customer.email}</td>
                <td>{customer.country}</td>
                <td>
                  <span className={`${styles.status} ${styles[customer.status]}`}>
                    {customer.status}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <footer className={styles.tableFooter}>
        <p className={styles.tableInfo}>
          Showing data 1 to 8 of 256K entries
        </p>
        <Pagination
          currentPage={1}
          totalPages={40}
          onPageChange={() => {}}
        />
      </footer>
    </section>
  );
};