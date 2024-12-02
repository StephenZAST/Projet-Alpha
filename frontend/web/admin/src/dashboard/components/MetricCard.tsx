import React from 'react';
import styles from './styles/MetricCard.module.css';
import { MetricCardProps } from '../types';

export const MetricCard: React.FC<MetricCardProps> = ({
  title,
  value,
  change,
  comparison
}) => {
  return (
    <article className={styles.metricCard}>
      <header className={styles.cardHeader}>
        <h3 className={styles.cardTitle}>{title}</h3>
        <p className={styles.cardValue}>{value}</p>
      </header>
      {change && (
        <footer className={styles.cardFooter}>
          <span className={`${styles.badge} ${styles[change.type]}`}>
            {change.value} ({change.type})
          </span>
          {comparison && (
            <span className={styles.comparison}>{comparison}</span>
          )}
        </footer>
      )}
    </article>
  );
};
