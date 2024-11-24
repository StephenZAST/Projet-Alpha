import React from 'react';
import styles from './Sidebar.module.css';

interface SidebarItem {
  icon: string;
  label: string;
  value: string;
}

interface SidebarProps {
  items: SidebarItem[];
  selectedView: string;
  onViewChange: (view: string) => void;
  isOpen: boolean;
  onToggle: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({
  items,
  selectedView,
  onViewChange,
  isOpen,
  onToggle
}) => {
  return (
    <>
      <button 
        className={styles.menuButton} 
        onClick={onToggle}
        aria-label="Toggle menu"
      >
        <span className={styles.menuIcon} />
      </button>
      
      <nav className={`${styles.sidebar} ${isOpen ? styles.open : ''}`}>
        <div className={styles.logo}>
          <img src="/logo.svg" alt="Company logo" />
        </div>
        
        <ul className={styles.menu}>
          {items.map((item) => (
            <li key={item.value}>
              <button
                className={`${styles.menuItem} ${
                  selectedView === item.value ? styles.active : ''
                }`}
                onClick={() => onViewChange(item.value)}
                aria-current={selectedView === item.value ? 'page' : undefined}
              >
                <img 
                  src={item.icon} 
                  alt="" 
                  className={styles.icon} 
                  aria-hidden="true"
                />
                <span className={styles.label}>{item.label}</span>
              </button>
            </li>
          ))}
        </ul>
      </nav>
    </>
  );
};