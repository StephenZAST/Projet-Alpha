import React from 'react';
import { SidebarItemProps } from '../types';
import styles from './style/SidebarItem.module.css';

export const SidebarItem: React.FC<SidebarItemProps> = ({
  icon,
  label,
  isActive,
  onClick
}) => {
  return (
    <button
      className={`${styles.sidebarItem} ${isActive ? styles.active : ''}`}
      onClick={onClick}
    >
      <img src={icon} alt="" className={styles.icon} />
      <span className={styles.label}>{label}</span>
    </button>
  );
};