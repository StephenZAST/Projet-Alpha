import React from 'react';
import { useState } from 'react';
import { ChevronDown, ChevronUp } from 'react-feather';
import { colors } from '../../theme/colors';

interface Column<T> {
  key: keyof T | 'actions';
  label: string;
  sortable?: boolean;
  render?: (value: unknown, item: T) => React.ReactNode;
}

interface DataTableProps<T> {
  data: T[];
  columns: Column<T>[];
  onSort?: (key: keyof T, direction: 'asc' | 'desc') => void;
  loading?: boolean;
}

export const DataTable = <T extends { id: string | number }>({ 
  data, 
  columns, 
  onSort,
  loading 
}: DataTableProps<T>) => {
  const [sortConfig, setSortConfig] = useState<{
    key: keyof T;
    direction: 'asc' | 'desc';
  } | null>(null);

  const handleSort = (key: keyof T) => {
    const direction = sortConfig?.key === key && sortConfig.direction === 'asc' ? 'desc' : 'asc';
    setSortConfig({ key, direction });
    onSort?.(key, direction);
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div style={{ overflowX: 'auto' }}>
      <table style={{ 
        width: '100%', 
        borderCollapse: 'collapse',
        backgroundColor: colors.white,
        borderRadius: '8px',
        overflow: 'hidden'
      }}>
        <thead>
          <tr>
            {columns.map(column => (
              <th
                key={String(column.key)}
                onClick={() => column.sortable && handleSort(column.key)}
                style={{
                  padding: '12px 16px',
                  textAlign: 'left',
                  backgroundColor: colors.gray50,
                  borderBottom: `1px solid ${colors.gray200}`,
                  cursor: column.sortable ? 'pointer' : 'default',
                  userSelect: 'none'
                }}
              >
                <div style={{ 
                  display: 'flex', 
                  alignItems: 'center', 
                  gap: '4px' 
                }}>
                  {column.label}
                  {column.sortable && sortConfig?.key === column.key && (
                    sortConfig.direction === 'asc' ? <ChevronUp size={16} /> : <ChevronDown size={16} />
                  )}
                </div>
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.map((item, index) => (
            <tr key={item.id} style={{
              backgroundColor: index % 2 === 0 ? colors.white : colors.gray50
            }}>
              {columns.map(column => (
                <td
                  key={String(column.key)}
                  style={{
                    padding: '12px 16px',
                    borderBottom: `1px solid ${colors.gray200}`
                  }}
                >
                  {column.render 
                    ? column.render(item[column.key], item)
                    : String(item[column.key])
                  }
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};
