import React from 'react';
import styles from '../styles/CustomerTable.module.css';

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
        <h2 className={styles.tableTitle}>{title}</h2>
        <div className={styles.tableActions}>
          {onSearch && (
            <form className={styles.searchForm}>
              <input
                type="search"
                placeholder="Search"
                className={styles.searchInput}
                onChange={(e) => onSearch(e.target.value)}
              />
            </form>
          )}
          {onSort && (
            <div className={styles.sortDropdown}>
              <select className={styles.sortSelect} onChange={(e) => onSort(e.target.value)}>
                <option value="newest">Newest</option>
                <option value="oldest">Oldest</option>
              </select>
            </div>
          )}
        </div>
      </header>

      <div className={styles.tableWrapper}>
        <table className={styles.table}>
          <thead>
            <tr>
              {headers.map((header, index) => (
                <th key={index}>{header}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {data.map((row, index) => (
              <tr key={index}>
                {Object.values(row).map((cell: any, cellIndex) => (
                  <td key={cellIndex}>{cell}</td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </section>
  );
};
