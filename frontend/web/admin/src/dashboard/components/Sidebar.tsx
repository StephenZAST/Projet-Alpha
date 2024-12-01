import React from 'react';
import styles from './styles/Sidebar.module.css';
import { SidebarItemProps } from '../types';
import { AdminNavConfig } from '../types/adminTypes';

interface SidebarProps {
  navConfig: AdminNavConfig;
}

const SidebarItem: React.FC<SidebarItemProps> = ({
  icon,
  label,
  isActive,
  onClick
}) => (
  <button
    className={`${styles.sidebarItem} ${isActive ? styles.active : ''}`}
    onClick={onClick}
    aria-current={isActive ? 'page' : undefined}
  >
    <img src={icon} alt="" className={styles.itemIcon} />
    <span className={styles.itemLabel}>{label}</span>
  </button>
);

export const Sidebar: React.FC<SidebarProps> = ({ navConfig }) => {
  const menuItems = navConfig.navItems.map((item) => ({
    icon: item.icon,
    label: item.label,
    isActive: false, // You'll need to determine active state based on current route
    onClick: () => {
      // Handle navigation to the item's path
      console.log(`Navigating to ${item.path}`);
    }
  }));

  return (
    <aside className={styles.sidebar}>
      <div className={styles.logoContainer}>
        <img
          src="https://cdn.builder.io/api/v1/image/assets/315113f1f03b4ff2a19c7d36a40da083/1de7076db066f8ab642f6f06d8bcda290f5f73532629ca03d573b888b3969eb8?apiKey=315113f1f03b4ff2a19c7d36a40da083&"
          alt="Alpha Laundry Logo"
          className={styles.logo}
        />
        <h1 className={styles.logoText}>
          <span className={styles.brandName}>ALPHA</span>
          <span className={styles.brandType}>LAUNDRY</span>
        </h1>
      </div>

      <nav className={styles.navigation}>
        {menuItems.map((item, index) => (
          <SidebarItem key={index} {...item} />
        ))}
      </nav>

      <button className={styles.signOutButton}>
        <img src="https://cdn.builder.io/api/v1/image/assets/315113f1f03b4ff2a19c7d36a40da083/c240ae9163230b874f317df3223620d8fdbbbda8704afff144012c67a73f5201?apiKey=315113f1f03b4ff2a19c7d36a40da083&" alt="" className={styles.signOutIcon} />
        <span>Sign Out</span>
      </button>
    </aside>
  );
};
