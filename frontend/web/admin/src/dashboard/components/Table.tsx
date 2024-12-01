import React from 'react';
import styles from './styles/CustomerTable.module.css';
import { Pagination } from './Pagination';
import { CustomerTableProps } from '../types';

export const Table: React.FC<CustomerTableProps> = ({
  customers,
  headers,
  onSearch,
  onSort,
  title = "All Data"
}) => {
  return (
    <section className={styles.tableContainer}>
      <header className={styles.tableHeader}>
        <h2 className={styles.tableTitle}>{title}</h2>
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
              onChange={(e) => onSearch?.(e.target.value)}
            />
          </form>
          <div className={styles.sortDropdown}>
            <span>Sort by: </span>
            <select className={styles.sortSelect} onChange={(e) => onSort?.(e.target.value)}>
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
              {headers.map((header, index) => (
                <th key={index} onClick={() => onSort?.(header)}>
                  {header}
                </th>
              ))}
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
