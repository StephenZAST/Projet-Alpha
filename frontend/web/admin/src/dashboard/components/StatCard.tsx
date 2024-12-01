import React from 'react';
import styles from '../styles/StatCard.module.css';
import { StatCardProps } from '../types';

export const StatCard: React.FC<StatCardProps> = ({
  icon,
  title,
  value,
  trend
}) => {
  return (
    <article className={styles.statCard}>
      <div className={styles.cardContent}>
        <img src={icon} alt="" className={styles.cardIcon} />
        <div className={styles.cardInfo}>
          <h3 className={styles.cardTitle}>{title}</h3>
          <p className={styles.cardValue}>{value}</p>
          {trend && (
            <div className={styles.cardTrend}>
              <img
                src={trend.direction === 'up' ? '/up-arrow.svg' : '/down-arrow.svg'}
                alt=""
                className={styles.trendIcon}
              />
              <span className={`${styles.trendValue} ${styles[trend.direction]}`}>
                {trend.value}
              </span>
              <span className={styles.trendText}>{trend.text}</span>
            </div>
          )}
        </div>
      </div>
    </article>
  );
};