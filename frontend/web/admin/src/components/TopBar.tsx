import React from 'react';
import { SearchBar } from './SearchBar';
import styles from './style/TopBar.module.css';

interface TopBarProps {
  onMenuClick: () => void;
}

export const TopBar: React.FC<TopBarProps> = ({ onMenuClick }) => {
  return (
    <header className={styles.topBar}>
      <button 
        className={styles.menuButton}
        onClick={onMenuClick}
        aria-label="Toggle menu"
      >
        <img src="/icons/menu.svg" alt="" />
      </button>

      <SearchBar onSearch={(value) => console.log('Search:', value)} />

      <div className={styles.actions}>
        <button className={styles.iconButton} aria-label="Notifications">
          <img src="/icons/notification.svg" alt="" />
          <span className={styles.badge}>3</span>
        </button>

        <button className={styles.iconButton} aria-label="Messages">
          <img src="/icons/message.svg" alt="" />
          <span className={styles.badge}>5</span>
        </button>

        <div className={styles.userProfile}>
          <img 
            src="/avatars/user.jpg" 
            alt="User avatar" 
            className={styles.avatar}
          />
          <span className={styles.userName}>John Doe</span>
        </div>
      </div>
    </header>
  );
};