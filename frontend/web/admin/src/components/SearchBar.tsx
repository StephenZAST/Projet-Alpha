import React from 'react';
import { SearchBarProps } from '../types';
import styles from './style/SearchBar.module.css';

export const SearchBar: React.FC<SearchBarProps> = ({
  placeholder = 'Search...',
  onSearch,
}) => {
  return (
    <form className={styles.searchForm} onSubmit={(e) => e.preventDefault()}>
      <label htmlFor="searchInput" className="sr-only">Search</label>
      <input
        type="search"
        id="searchInput"
        className={styles.searchInput}
        placeholder={placeholder}
        onChange={(e) => onSearch(e.target.value)}
      />
      <button type="submit" className={styles.searchButton} aria-label="Search">
        <img
          src="https://cdn.builder.io/api/v1/image/assets/315113f1f03b4ff2a19c7d36a40da083/2b7a7806b2e084dec760df39f0d4a50eba32a53e0ae26e14bdd85786e48429e7?apiKey=315113f1f03b4ff2a19c7d36a40da083&"
          alt=""
          className={styles.searchIcon}
        />
      </button>
    </form>
  );
};
