import React from 'react';
import styles from '../styles/MetricCard.module.css';
import { MetricCardProps } from '../types';

export const MetricCard: React.FC<MetricCardProps> = ({
  title,
  value,
  change,
  changeType = 'neutral',
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
          <span className={`${styles.badge} ${styles[changeType]}`}>
            {change}
          </span>
          {comparison && (
            <span className={styles.comparison}>{comparison}</span>
          )}
        </footer>
      )}
    </article>
  );
};

.metricCard {
    background: var(--white);
    border-radius: 20px;
    padding: 24px;
    box-shadow: var(--pripary-box-shadow);
  }
  
  .cardHeader {
    margin-bottom: 16px;
  }
  
  .cardTitle {
    color: var(--gray-600);
    font-size: 16px;
    font-weight: 400;
    margin-bottom: 8px;
  }
  
  .cardValue {
    color: var(--gray-900);
    font-size: 26px;
    font-weight: 600;
    line-height: 1.2;
  }
  
  .cardFooter {
    display: flex;
    align-items: center;
    gap: 8px;
  }
  
  .badge {
    padding: 4px 8px;
    border-radius: 100px;
    font-size: 12px;
    font-weight: 600;
  }
  
  .positive {
    background-color: var(--success-light);
    color: var(--success);
  }
  
  .negative {
    background-color: var(--error-light);
    color: var(--error);
  }
  
  .neutral {
    background-color: var(--gray-100);
    color: var(--gray-600);
  }
  
  .comparison {
    color: var(--gray-500);
    font-size: 12px;
  }
  
  @media (max-width: 768px) {
    .metricCard {
      padding: 16px;
    }
  
    .cardValue {
      font-size: 22px;
    }
  }

  _____________________

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



.statCard {
  background: var(--primary-gradient);
  border-radius: 20px;
  padding: 24px;
  box-shadow: var(--pripary-box-shadow);
}

.cardContent {
  display: flex;
  gap: 20px;
}

.cardIcon {
  width: 84px;
  height: 84px;
  object-fit: contain;
}

.cardInfo {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.cardTitle {
  color: var(--gray-100);
  font-size: 14px;
  font-weight: 400;
}

.cardValue {
  color: var(--absolute-white);
  font-size: 32px;
  font-weight: 600;
  line-height: 1;
}

.cardTrend {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
}

.trendIcon {
  width: 20px;
  height: 20px;
}

.trendValue {
  font-weight: 700;
}

.trendValue.up {
  color: var(--success);
}

.trendValue.down {
  color: var(--error);
}

.trendText {
  color: var(--white);
}

@media (max-width: 768px) {
  .statCard {
    padding: 16px;
  }

  .cardIcon {
    width: 64px;
    height: 64px;
  }

  .cardValue {
    font-size: 24px;
  }
}