import React from 'react';
import styles from './TopBar.module.css';
import { IconButtonProps } from './types';

export const IconButton: React.FC<IconButtonProps> = ({ src, alt, onClick }) => (
  <button 
    className={styles.iconButton} 
    onClick={onClick}
    tabIndex={0}
    aria-label={alt}
  >
    <img
      loading="lazy"
      src={src}
      alt={alt}
      className={styles.iconImage}
    />
  </button>
);