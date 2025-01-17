import React from 'react';
import { colors } from '../../theme/colors';

interface StatCardProps {
  title: string;
  value: string | number;
  icon?: React.ReactNode;
  change?: number;
}

export const StatCard: React.FC<StatCardProps> = ({ title, value, icon, change }) => {
  return (
    <div style={{
      padding: '24px',
      backgroundColor: colors.white,
      borderRadius: '12px',
      boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
      minWidth: '240px'
    }}>
      <div style={{ marginBottom: '8px' }}>{icon}</div>
      <h3 style={{ fontSize: '14px', color: colors.gray600 }}>{title}</h3>
      <p style={{ fontSize: '24px', fontWeight: 600, margin: '8px 0' }}>{value}</p>
      {change !== undefined && (
        <span style={{ 
          color: change > 0 ? colors.success : colors.error,
          fontSize: '14px'
        }}>
          {change > 0 ? '+' : ''}{change}%
        </span>
      )}
    </div>
  );
};