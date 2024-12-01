import React from 'react';
import styles from './TopBar.module.css';
import { IconButton } from './IconButton';
import { SearchInput } from './SearchInput';
import { UserAvatar } from './UserAvatar';

interface TopBarProps {
  onThemeToggle: () => void;
}

export const TopBar: React.FC<TopBarProps> = ({ onThemeToggle }) => {
  const handleSearch = (value: string) => {
    console.log('Search:', value);
  };

  const iconButtons = [
    { src: "https://cdn.builder.io/api/v1/image/assets/d706677ec2b549059d642cb9fb9fad8c/3fb10766d5fa0e43a6ef8b8db27a554d388bd1a4ea455f45200b46c8608f35bd?apiKey=d706677ec2b549059d642cb9fb9fad8c&", alt: "Calendar" },
    { src: "https://cdn.builder.io/api/v1/image/assets/d706677ec2b549059d642cb9fb9fad8c/d3a66b673bcc96d3feb97663871e59b48deea1beca48719154dfaef787dd3ce7?apiKey=d706677ec2b549059d642cb9fb9fad8c&", alt: "Notifications" }
  ];

  return (
    <header className={styles.topBar}>
      <UserAvatar 
        userName="Evano"
        imageSrc="https://cdn.builder.io/api/v1/image/assets/d706677ec2b549059d642cb9fb9fad8c/cac9f54752c567c2d16bf509b2c7f68d3487cf5e9b3fc4e0bbd0b6c8687fa33f?apiKey=d706677ec2b549059d642cb9fb9fad8c&"
      />
      
      <SearchInput onSearch={handleSearch} />
      
      <div className={styles.actionsContainer}>
        <div className={styles.iconButtonsGroup}>
          {iconButtons.map((button, index) => (
            <IconButton
              key={index}
              src={button.src}
              alt={button.alt}
            />
          ))}
          <button className={styles.themeToggle} onClick={onThemeToggle}>
            Toggle Theme
          </button>
        </div>
        <div className={styles.brandLogo}>
          <img
            loading="lazy"
            src="https://cdn.builder.io/api/v1/image/assets/d706677ec2b549059d642cb9fb9fad8c/654b9fd69d9fed634e8c2e061fc02a9bf5790aab87cd124935ad86b00045bfaf?apiKey=d706677ec2b549059d642cb9fb9fad8c&"
            alt="Brand logo"
            className={styles.logoImage}
          />
        </div>
      </div>
    </header>
  );
};
