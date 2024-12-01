import React from 'react';
import styles from './StatCard.module.css';

interface StatCardProps {
  title: string;
  value: string | number;
  icon?: string;
  trend?: {
    value: string;
    direction: 'up' | 'down';
    text?: string;
  };
  className?: string;
}

export const StatCard: React.FC<StatCardProps> = ({
  title,
  value,
  icon,
  trend,
  className = '',
}) => {
  return (
    <div className={`${styles.statCard} ${className}`}>
      <div className={styles.header}>
        {icon && (
          <div className={styles.iconWrapper}>
            <span className="material-icons">{icon}</span>
          </div>
        )}
        <h3 className={styles.title}>{title}</h3>
      </div>
      
      <div className={styles.content}>
        <div className={styles.value}>{value}</div>
        {trend && (
          <div className={`${styles.trend} ${styles[trend.direction]}`}>
            <span className="material-icons">
              {trend.direction === 'up' ? 'arrow_upward' : 'arrow_downward'}
            </span>
            <span className={styles.trendValue}>{trend.value}</span>
            {trend.text && <span className={styles.trendText}>{trend.text}</span>}
          </div>
        )}
      </div>
    </div>
  );
};
