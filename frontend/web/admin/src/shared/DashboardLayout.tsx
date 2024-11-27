import React, { useState } from 'react';
import { ThemeProvider } from '../theme/ThemeProvider'; // Specifying the named export
import { Sidebar } from './Sidebar';
import { TopBar } from './TopBar';
import styles from './DashboardLayout.module.css';

interface SidebarItem {
  icon: string;
  label: string;
  value: string;
}

interface DashboardLayoutProps {
  children: React.ReactNode;
  sidebarItems: SidebarItem[];
  selectedView: string;
  onViewChange: (view: string) => void;
  userRole: string;
}

export const DashboardLayout: React.FC<DashboardLayoutProps> = ({
  children,
  sidebarItems,
  selectedView,
  onViewChange,
  userRole
}) => {
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);

  return (
    <ThemeProvider>
      <div className={styles.dashboardContainer}>
        <Sidebar 
          items={sidebarItems}
          selectedView={selectedView}
          onViewChange={onViewChange}
          isOpen={isSidebarOpen}
          onToggle={() => setIsSidebarOpen(!isSidebarOpen)}
        />
        <div className={styles.mainContent}>
          <TopBar 
            userRole={userRole}
            onMenuClick={() => setIsSidebarOpen(!isSidebarOpen)}
          />
          <main className={styles.contentArea}>
            {children}
          </main>
        </div>
      </div>
    </ThemeProvider>
  );
};
