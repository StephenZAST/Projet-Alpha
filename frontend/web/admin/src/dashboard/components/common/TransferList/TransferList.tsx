import React from 'react';
import styles from './TransferList.module.css';

interface Transfer {
  id: string;
  from?: {
    name: string;
    avatar: string;
  };
  to?: {
    name: string;
    avatar: string;
  };
  amount: number;
  date: string;
  time: string;
}

interface TransferListProps {
  transfers: Transfer[];
  title?: string;
  className?: string;
}

export const TransferList: React.FC<TransferListProps> = ({
  transfers,
  title = 'Your Transfers',
  className = '',
}) => {
  return (
    <div className={`${styles.transferList} ${className}`}>
      <div className={styles.header}>
        <h3 className={styles.title}>{title}</h3>
      </div>
      
      <div className={styles.list}>
        {transfers.map((transfer) => (
          <div key={transfer.id} className={styles.transferItem}>
            <div className={styles.userInfo}>
              {transfer.from ? (
                <>
                  <img src={transfer.from.avatar} alt="" className={styles.avatar} />
                  <div className={styles.details}>
                    <span className={styles.label}>From {transfer.from.name}</span>
                    <span className={styles.time}>{transfer.time}</span>
                  </div>
                </>
              ) : (
                <>
                  <img src={transfer.to?.avatar} alt="" className={styles.avatar} />
                  <div className={styles.details}>
                    <span className={styles.label}>To {transfer.to?.name}</span>
                    <span className={styles.time}>{transfer.time}</span>
                  </div>
                </>
              )}
            </div>
            
            <div className={`${styles.amount} ${transfer.from ? styles.positive : styles.negative}`}>
              {transfer.from ? '+' : '-'}${Math.abs(transfer.amount)}
            </div>
          </div>
        ))}
      </div>
      
      <button className={styles.viewAll}>
        View all
        <span className="material-icons">arrow_forward</span>
      </button>
    </div>
  );
};
