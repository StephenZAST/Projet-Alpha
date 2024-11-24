import React from 'react';
import styles from './TopBar.module.css';

interface TopBarProps {
  userRole: string;
  onMenuClick: () => void;
}

export const TopBar: React.FC<TopBarProps> = ({ userRole, onMenuClick }) => {
  return (
    <header className={styles.topBar}>
      <div className={styles.search}>
        <input 
          type="search" 
          placeholder="Rechercher..." 
          className={styles.searchInput}
          aria-label="Search"
        />
      </div>
      
      <div className={styles.actions}>
        <button 
          className={styles.iconButton} 
          aria-label="Notifications"
        >
          <img src="/icons/notification.svg" alt="" aria-hidden="true" />
          <span className={styles.badge}>3</span>
        </button>
        
        <button 
          className={styles.iconButton}
          aria-label="Messages"
        >
          <img src="/icons/message.svg" alt="" aria-hidden="true" />
          <span className={styles.badge}>5</span>
        </button>
        
        <div className={styles.userInfo}>
          <img 
            src="/avatar-placeholder.jpg" 
            alt="" 
            className={styles.avatar}
          />
          <div className={styles.userDetails}>
            <span className={styles.userName}>John Doe</span>
            <span className={styles.userRole}>{userRole}</span>
          </div>
        </div>
      </div>
    </header>
  );
};