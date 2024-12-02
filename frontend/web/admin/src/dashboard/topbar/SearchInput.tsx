import React from 'react';
import styles from './TopBar.module.css';
import { SearchInputProps } from './types';

export const SearchInput: React.FC<SearchInputProps> = ({ onSearch, placeholder = 'Search...' }) => (
  <form className={styles.searchForm} role="search">
    <label htmlFor="searchInput" className={styles.visuallyHidden}>
      Search
    </label>
    <div className={styles.searchInputWrapper}>
      <img
        loading="lazy"
        src="https://cdn.builder.io/api/v1/image/assets/d706677ec2b549059d642cb9fb9fad8c/f9b1ae9cb3b9ced8e4cdbd953a49abea62fb44e850654c876a600fd691feaf2a?apiKey=d706677ec2b549059d642cb9fb9fad8c&"
        alt=""
        className={styles.searchIcon}
      />
      <input
        id="searchInput"
        type="search"
        className={styles.searchInput}
        placeholder={placeholder}
        onChange={(e) => onSearch(e.target.value)}
        aria-label="Search"
      />
    </div>
  </form>
);