import React from 'react';
import { useTheme } from '../hooks/useTheme';
import styles from './style//ThemeToggle.module.css';

export const ThemeToggle: React.FC = () => {
  const { theme, toggleTheme } = useTheme();

  return (
    <button 
      className={`${styles.themeToggle} ${styles[theme]}`}
      onClick={toggleTheme}
      aria-label={`Switch to ${theme === 'light' ? 'dark' : 'light'} mode`}
    >
      <div className={styles.toggleTrack}>
        <img 
          src="/icons/sun.svg" 
          alt="" 
          className={styles.sunIcon}
        />
        <img 
          src="/icons/moon.svg" 
          alt="" 
          className={styles.moonIcon}
        />
      </div>
      <div className={styles.toggleThumb} />
    </button>
  );
};