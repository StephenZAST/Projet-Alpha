import React from 'react';

interface StatCardProps {
  title: string;
  value: number | string;
  change?: number;
}

export const StatCard: React.FC<StatCardProps> = ({ title, value, change }) => {
  return (
    <div style={{ 
      backgroundColor: '#fff', 
      padding: '16px', 
      borderRadius: '8px', 
      boxShadow: '0 1px 3px rgba(0,0,0,0.1)' 
    }}>
      <h3>{title}</h3>
      <p>{value}</p>
      {change !== undefined && <p>{change > 0 ? `+${change}` : change}%</p>}
    </div>
  );
};
