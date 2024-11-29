import React, { useState } from 'react';
import { SidebarItem } from '../../components/SidebarItem';
import { TopBar } from '../../components/TopBar';
import { ThemeToggle } from '../../components/ThemeToggle';
import styles from '../style/DashboardLayout.module.css';

interface DashboardLayoutProps {
  children: React.ReactNode;
  sidebarItems: Array<{
    icon: string;
    label: string;
    value: string;
  }>;
  selectedView: string;
  onViewChange: (view: string) => void;
  userRole: string;
}

export const DashboardLayout: React.FC<DashboardLayoutProps> = ({
  children,
  sidebarItems,
  selectedView,
  onViewChange}) => {
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);

  const toggleSidebar = () => {
    setIsSidebarOpen(!isSidebarOpen);
  };

  return (
    <div className={styles.dashboardContainer}>
      <aside className={`${styles.sidebar} ${isSidebarOpen ? styles.sidebarOpen : ''}`}>
        <div className={styles.logoContainer}>
          <img src="/logo.svg" alt="Logo" className={styles.logo} />
          <h1 className={styles.logoText}>
            <span className={styles.brandName}>ALPHA</span>
            <span className={styles.brandType}>LAUNDRY</span>
          </h1>
        </div>

        <nav className={styles.navigation}>
          {sidebarItems.map((item) => (
            <SidebarItem
              key={item.value}
              icon={item.icon}
              label={item.label}
              isActive={selectedView === item.value}
              onClick={() => {
                onViewChange(item.value);
                if (window.innerWidth < 768) {
                  setIsSidebarOpen(false);
                }
              }}
            />
          ))}
        </nav>

        <div className={styles.sidebarFooter}>
          <ThemeToggle />
          <button className={styles.logoutButton}>
            <img src="/icons/logout.svg" alt="" />
            <span>Déconnexion</span>
          </button>
        </div>
      </aside>

      <main className={styles.mainContainer}>
        <TopBar onMenuClick={toggleSidebar} />
        <div className={styles.contentWrapper}>
          {children}
        </div>
      </main>
    </div>
  );
};
