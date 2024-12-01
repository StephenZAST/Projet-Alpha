import React from 'react';
import styles from '../styles/Pagination.module.css';
import { PaginationProps } from '../types';

export const Pagination: React.FC<PaginationProps> = ({
  currentPage,
  totalPages,
  onPageChange
}) => {
  return (
    <nav className={styles.pagination} aria-label="Pagination">
      <button
        className={styles.pageButton}
        onClick={() => onPageChange(currentPage - 1)}
        disabled={currentPage === 1}
        aria-label="Previous page"
      >
        &lt;
      </button>
      
      {[...Array(Math.min(5, totalPages))].map((_, i) => (
        <button
          key={i}
          className={`${styles.pageButton} ${
            currentPage === i + 1 ? styles.active : ''
          }`}
          onClick={() => onPageChange(i + 1)}
          aria-label={`Page ${i + 1}`}
          aria-current={currentPage === i + 1 ? 'page' : undefined}
        >
          {i + 1}
        </button>
      ))}

      {totalPages > 5 && (
        <>
          <span className={styles.ellipsis}>...</span>
          <button
            className={styles.pageButton}
            onClick={() => onPageChange(totalPages)}
            aria-label={`Page ${totalPages}`}
          >
            {totalPages}
          </button>
        </>
      )}

      <button
        className={styles.pageButton}
        onClick={() => onPageChange(currentPage + 1)}
        disabled={currentPage === totalPages}
        aria-label="Next page"
      >
        &gt;
      </button>
    </nav>
  );
};