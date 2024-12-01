import React from 'react';
import styles from '../styles/Sidebar.module.css';
import { SidebarItemProps } from '../types';

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

export const Sidebar: React.FC = () => {
  const menuItems = [
    { icon: 'https://cdn.builder.io/api/v1/image/assets/315113f1f03b4ff2a19c7d36a40da083/8320672ea383dcf734ac58d30ecb2a17373d8d25c9304a88b4922919220d82f9?apiKey=315113f1f03b4ff2a19c7d36a40da083&', label: 'Home', isActive: true },
    { icon: 'https://cdn.builder.io/api/v1/image/assets/315113f1f03b4ff2a19c7d36a40da083/2f64e910cbba81833281c9696735979418ed92794a3e8e0c3a0ed191bc85acea?apiKey=315113f1f03b4ff2a19c7d36a40da083&', label: 'Offres' },
    { icon: 'https://cdn.builder.io/api/v1/image/assets/315113f1f03b4ff2a19c7d36a40da083/264e1bbbeb65dd62d2859be7e12b89f96fe178f35b0fbffef6fc8d48e8bbd6c3?apiKey=315113f1f03b4ff2a19c7d36a40da083&', label: 'Services' },
    { icon: 'https://cdn.builder.io/api/v1/image/assets/315113f1f03b4ff2a19c7d36a40da083/1f08baf546b1d73b0daec35ae6f4832d58c70490f5ebe8d0fdedba7bd5e75743?apiKey=315113f1f03b4ff2a19c7d36a40da083&', label: 'Commandes' },
    { icon: 'https://cdn.builder.io/api/v1/image/assets/315113f1f03b4ff2a19c7d36a40da083/d26e31f9d4d8d27fe65551a06fa1c3cf7ff9b2bb602239db824cec50591a5b27?apiKey=315113f1f03b4ff2a19c7d36a40da083&', label: 'Notifications' },
    { icon: 'https://cdn.builder.io/api/v1/image/assets/315113f1f03b4ff2a19c7d36a40da083/9598e5cf402516940e6502de106164342315f868a050cc9b55b439d49ea2c19a?apiKey=315113f1f03b4ff2a19c7d36a40da083&', label: 'Messages' },
    { icon: 'https://cdn.builder.io/api/v1/image/assets/315113f1f03b4ff2a19c7d36a40da083/542947db35873db1f3d2af97fc425ea7d97ac4787753dd2f5ad7807f7abd7d5c?apiKey=315113f1f03b4ff2a19c7d36a40da083&', label: 'Parrainage' },
    { icon: 'https://cdn.builder.io/api/v1/image/assets/315113f1f03b4ff2a19c7d36a40da083/b1f1c97c07973b281f964809daabceeef095f1d5bee1776a988bddc3bce7268a?apiKey=315113f1f03b4ff2a19c7d36a40da083&', label: 'Profile' },
    { icon: 'https://cdn.builder.io/api/v1/image/assets/315113f1f03b4ff2a19c7d36a40da083/2179d5587fc3c9fa869a500eab02161fcaf36c17c1bc4485fa264e7d3f079ffd?apiKey=315113f1f03b4ff2a19c7d36a40da083&', label: 'Settings' }
  ];

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