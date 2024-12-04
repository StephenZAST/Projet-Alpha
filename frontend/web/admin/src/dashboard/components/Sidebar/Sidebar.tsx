import React from 'react';
import { Link } from '@tanstack/react-router';
import styles from './Sidebar.module.css';
import { AdminNavConfig } from '../../types/adminTypes';

interface SidebarProps {
  navConfig: AdminNavConfig;
}

export const Sidebar: React.FC<SidebarProps> = ({ navConfig }) => {
  return (
    <aside className={styles.sidebar}>
      <div className={styles.logo}>
        <img src="/logo.svg" alt="Logo" className={styles.logoImage} />
        <span className={styles.logoText}>Admin Dashboard</span>
      </div>

      <nav className={styles.navigation}>
        {navConfig.navItems.map((item) => (
          <Link
            key={item.id}
            to={`/dashboard/${item.path}`}
            className={styles.navItem}
            activeProps={{ className: `${styles.navItem} ${styles.active}` }}
          >
            <span className="material-icons">{item.icon}</span>
            <span className={styles.navLabel}>{item.label}</span>
          </Link>
        ))}
      </nav>
    </aside>
  );
};

export default Sidebar;
