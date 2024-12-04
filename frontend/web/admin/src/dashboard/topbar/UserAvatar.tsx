import React from 'react';
import styles from './TopBar.module.css';
import { UserAvatarProps } from './types';

export const UserAvatar: React.FC<UserAvatarProps> = ({ userName }) => (
  <div className={styles.userGreeting}>
    <h1 className={styles.greeting}>Hello {userName} 👋🏼,</h1>
  </div>
);