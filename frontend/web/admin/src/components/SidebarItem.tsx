import React from 'react';
import styles from './SidebarItem.module.css';

interface SidebarItemProps {
  icon: string;
  label: string;
  isActive: boolean;
  onClick: () => void;
}

export const SidebarItem: React.FC<SidebarItemProps> = ({
  icon,
  label,
  isActive,
  onClick,
}) => {
  return (
    <button
      className={`${styles.sidebarItem} ${isActive ? styles.active : ''}`}
      onClick={onClick}
      type="button"
    >
      <img src={icon} alt="" className={styles.icon} />
      <span className={styles.label}>{label}</span>
    </button>
  );
};