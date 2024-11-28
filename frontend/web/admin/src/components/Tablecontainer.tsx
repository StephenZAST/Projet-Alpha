import React, { useState } from 'react';
import styles from './style/Table.module.css';

interface TableProps<T> {
  data: T[];
  columns: {
    key: string;
    label: string;
    render?: (item: T) => React.ReactNode;
  }[];
}

const Table: React.FC<TableProps<T>> = ({ data, columns }) => { // Add <T> here
  const [sortOrder, setSortOrder] = useState<{ key: string; direction: 'asc' | 'desc' } | null>(null);

  const handleSort = (key: string) => {
    if (sortOrder && sortOrder.key === key) {
      setSortOrder({ key, direction: sortOrder.direction === 'asc' ? 'desc' : 'asc' });
    } else {
      setSortOrder({ key, direction: 'asc' });
    }
  };

  const sortedData = sortOrder
    ? [...data].sort((a, b) => {
        const aValue = a[sortOrder.key];
        const bValue = b[sortOrder.key];
        if (aValue < bValue) return sortOrder.direction === 'asc' ? -1 : 1;
        if (aValue > bValue) return sortOrder.direction === 'asc' ? 1 : -1;
        return 0;
      })
    : data;

  return (
    <table className={styles.table}>
      <thead>
        <tr>
          {columns.map((column) => (
            <th key={column.key} onClick={() => handleSort(column.key)}>
              {column.label}
              {sortOrder && sortOrder.key === column.key && (
                <span>{sortOrder.direction === 'asc' ? ' ▲' : ' ▼'}</span>
              )}
            </th>
          ))}
        </tr>
      </thead>
      <tbody>
        {sortedData.map((item, index) => (
          <tr key={index}>
            {columns.map((column) => (
              <td key={column.key}>{column.render ? column.render(item) : item[column.key]}</td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
};

export default Table;
