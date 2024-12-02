import React from 'react';
import styles from './TopBar.module.css';
import { useTheme } from '../../App';

export const TopBar: React.FC = () => {
  const { theme, toggleTheme } = useTheme();

  return (
    <div className={styles.topBar}>
      <div className={styles.searchBar}>
        <input type="text" placeholder="Search..." />
      </div>
      
      <div className={styles.actions}>
        <button 
          onClick={toggleTheme}
          className={styles.themeToggle}
          aria-label={`Switch to ${theme === 'light' ? 'dark' : 'light'} mode`}
        >
          <span className="material-icons">
            {theme === 'light' ? 'dark_mode' : 'light_mode'}
          </span>
        </button>
        
        <div className={styles.userInfo}>
          <span className="material-icons">account_circle</span>
          <span>Admin</span>
        </div>
      </div>
    </div>
  );
};

export default TopBar;
