import React, { useState } from 'react';
import { DashboardLayout } from './DashboardLayout';
import { TeamPerformance } from '../components/TeamPerformance';
import { TeamManagement } from '../components/TeamManagement';
import { SupervisorReports } from '../components/SupervisorReports';
import { SupervisorConfig } from '../components/SupervisorConfig';
import styles from './style/SupervisorDashboard.module.css';

export const SupervisorDashboard: React.FC = () => {
  const [selectedView, setSelectedView] = useState('performance');

  const sidebarItems = [
    { icon: '/icons/performance.svg', label: 'Performance Équipe', value: 'performance' },
    { icon: '/icons/team.svg', label: 'Gestion Équipe', value: 'team' },
    { icon: '/icons/reports.svg', label: 'Rapports', value: 'reports' },
    { icon: '/icons/config.svg', label: 'Configuration', value: 'config' }
  ];

  const renderContent = () => {
    switch(selectedView) {
      case 'team':
        return <TeamManagement />;
      case 'reports':
        return <SupervisorReports />;
      case 'config':
        return <SupervisorConfig />;
      default:
        return <TeamPerformance />;
    }
  };

  return (
    <DashboardLayout
      sidebarItems={sidebarItems}
      selectedView={selectedView}
      onViewChange={setSelectedView}
      userRole="Supervisor"
    >
      <div className={styles.dashboardContent}>
        {renderContent()}
      </div>
    </DashboardLayout>
  );
};