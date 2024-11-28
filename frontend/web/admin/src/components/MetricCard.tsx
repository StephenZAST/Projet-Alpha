import React from 'react';
import styles from './style/MetricCard.module.css';

export interface MetricCardProps {
  title: string;
  value: string;
  change?: {
    value: string;
    type: 'increase' | 'decrease' | 'neutral';
    baseline?: string;
  };
}

export const MetricCard: React.FC<MetricCardProps> = ({ title, value, change }) => {
  const getBadgeClass = () => {
    if (!change) return '';
    return change.type === 'increase' ? styles.increaseBadge : 
           change.type === 'decrease' ? styles.decreaseBadge : 
           styles.neutralBadge;
  };

  return (
    <article className={styles.metricCard}>
      <header className={styles.header}>
        <h3 className={styles.title}>{title}</h3>
        <p className={styles.value}>{value}</p>
      </header>
      {change && (
        <div className={styles.info}>
          <span className={`${styles.badge} ${getBadgeClass()}`}>
            {change.value}
          </span>
          {change.baseline && (
            <span className={styles.baseline}>{change.baseline}</span>
          )}
        </div>
      )}
    </article>
  );
};
