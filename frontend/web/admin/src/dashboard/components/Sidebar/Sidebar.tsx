import React, { useEffect, useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import styles from './Sidebar.module.css';
import { AdminNavConfig } from '../../types/adminTypes';

interface SidebarProps {
  navConfig: AdminNavConfig;
}

export const Sidebar: React.FC<SidebarProps> = ({ navConfig }) => {
  const navigate = useNavigate();
  const location = useLocation();
  const [activeItem, setActiveItem] = useState<string>('');

  useEffect(() => {
    // Mise à jour de l'item actif basé sur le path actuel
    const currentPath = location.pathname.split('/').pop() || '';
    const activeNavItem = navConfig.navItems.find(item => item.path === currentPath);
    
    if (activeNavItem) {
      setActiveItem(activeNavItem.id);
    }
  }, [location.pathname, navConfig.navItems]);

  const handleNavigation = (path: string, id: string) => {
    console.log('Navigating to:', path);
    setActiveItem(id);
    // Navigation relative au dashboard
    navigate(path);
  };

  return (
    <aside className={styles.sidebar}>
      <div className={styles.logo}>
        <img src="/logo.svg" alt="Logo" className={styles.logoImage} />
        <span className={styles.logoText}>Admin Dashboard</span>
      </div>

      <nav className={styles.navigation}>
        {navConfig.navItems.map((item) => (
          <button
            key={item.id}
            className={`${styles.navItem} ${activeItem === item.id ? styles.active : ''}`}
            onClick={() => handleNavigation(item.path, item.id)}
          >
            <span className="material-icons">{item.icon}</span>
            <span className={styles.navLabel}>{item.label}</span>
          </button>
        ))}
      </nav>
    </aside>
  );
};

export default Sidebar;
