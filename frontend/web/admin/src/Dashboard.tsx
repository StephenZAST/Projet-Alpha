import React from 'react';
import { MetricCard } from './components/MetricCard';
import { SearchBar } from './components/SearchBar';
import { SidebarItem } from './components/SidebarItem';
import { CustomerTable } from './components/CustomerTable';
import styles from './Dashboard.module.css';

export const Dashboard: React.FC = () => {
  const handleSearch = (value: string) => {
    console.log('Search:', value);
  };

  return (
    <div className={styles.dashboardLayout}>
      <nav className={styles.sidebar}>
        <div className={styles.logo}>
          <img src="https://cdn.builder.io/api/v1/image/assets/315113f1f03b4ff2a19c7d36a40da083/513f997cf983544bc78a0a156432998f4b0dc72231f9ba423094ea66069d55fa?apiKey=315113f1f03b4ff2a19c7d36a40da083&" alt="Company Logo" />
        </div>
        
        <div className={styles.sidebarItems}>
          <SidebarItem
            icon="https://cdn.builder.io/api/v1/image/assets/315113f1f03b4ff2a19c7d36a40da083/67da1297acf88304ab633ce67ae0ce7b6919a2f226241ccc2f7b1bd5da5564d8?apiKey=315113f1f03b4ff2a19c7d36a40da083&"
            label="Home"
            isActive={true}
          />
          {/* Other sidebar items */}
        </div>
      </nav>

      <main className={styles.mainContent}>
        <header className={styles.topBar}>
          <SearchBar onSearch={handleSearch} />
          <div className={styles.userActions}>
            <button className={styles.notificationButton} aria-label="Notifications">
              <img src="https://cdn.builder.io/api/v1/image/assets/315113f1f03b4ff2a19c7d36a40da083/bfb4294d576bf9a84dd61cc88ab4976bbf083747eae201633c073577e878d23d?apiKey=315113f1f03b4ff2a19c7d36a40da083&" alt="" />
            </button>
            <img src="https://cdn.builder.io/api/v1/image/assets/315113f1f03b4ff2a19c7d36a40da083/012d1e9a8771165ece2c5a37e85f66d54b726a728aced6aad71c7f028cd56866?apiKey=315113f1f03b4ff2a19c7d36a40da083&" alt="User avatar" className={styles.userAvatar} />
          </div>
        </header>

        <div className={styles.dashboardContent}>
          <section className={styles.metrics}>
            <MetricCard
              title="Commandes en cours"
              value="125"
              change={{ value: "+45%", type: "increase", baseline: "From 4.6%" }}
            />
            {/* Other metric cards */}
          </section>

          <CustomerTable />
        </div>
      </main>
    </div>
  );
};