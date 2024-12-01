import React, { useEffect, useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import styles from './Sidebar.module.css';
import { AdminType, adminNavConfigs } from '../../types/adminTypes';
import { useAuth } from '../../../auth/AuthContext'; // Vous devrez créer ce hook

interface SidebarProps {
  className?: string;
}

export const Sidebar: React.FC<SidebarProps> = ({ className = '' }) => {
  const navigate = useNavigate();
  const location = useLocation();
  const { user } = useAuth(); // Hook pour obtenir les infos de l'utilisateur connecté
  const [activeItem, setActiveItem] = useState<string>('');

  // Obtenir la configuration de navigation pour le type d'admin actuel
  const adminType = user?.adminType as AdminType || 'CUSTOMER_SERVICE';
  const navConfig = adminNavConfigs[adminType];

  useEffect(() => {
    // Mettre à jour l'item actif basé sur le path actuel
    const currentPath = location.pathname;
    const activeNavItem = navConfig.navItems.find(item => 
      currentPath.startsWith(item.path)
    );
    if (activeNavItem) {
      setActiveItem(activeNavItem.id);
    }
  }, [location.pathname, navConfig.navItems]);

  const handleNavigation = (path: string, id: string) => {
    console.log('Navigating to:', path, 'with active item:', id); // Log the navigation
    setActiveItem(id);
    navigate(path);
  };

  return (
    <aside className={`${styles.sidebar} ${className}`}>
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
            <span className={`material-icons ${styles.icon}`}>{item.icon}</span>
            <span className={styles.title}>{item.title}</span>
          </button>
        ))}
      </nav>

      <div className={styles.userInfo}>
        <div className={styles.avatar}>
          <img src={user?.avatar || '/default-avatar.png'} alt="User avatar" />
        </div>
        <div className={styles.userDetails}>
          <span className={styles.userName}>{user?.firstName} {user?.lastName}</span>
          <span className={styles.userRole}>{adminType}</span>
        </div>
      </div>
    </aside>
  );
};
