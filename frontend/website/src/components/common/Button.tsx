/**
 * 🔘 Button Component - Réutilisable avec variantes
 * Support glassmorphism, animations et accessibilité
 */

import React from 'react';
import styles from './Button.module.css';

export type ButtonVariant = 'primary' | 'secondary' | 'success' | 'warning' | 'error' | 'info' | 'outline';
export type ButtonSize = 'small' | 'medium' | 'large';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  fullWidth?: boolean;
  isLoading?: boolean;
  icon?: React.ReactNode;
  iconPosition?: 'left' | 'right';
  children: React.ReactNode;
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  (
    {
      variant = 'primary',
      size = 'medium',
      fullWidth = false,
      isLoading = false,
      icon,
      iconPosition = 'left',
      children,
      className = '',
      disabled,
      ...props
    },
    ref
  ) => {
    const buttonClass = `
      ${styles.button}
      ${styles[variant]}
      ${styles[size]}
      ${fullWidth ? styles.fullWidth : ''}
      ${isLoading ? styles.loading : ''}
      ${disabled ? styles.disabled : ''}
      ${className}
    `.trim();

    return (
      <button
        ref={ref}
        className={buttonClass}
        disabled={disabled || isLoading}
        aria-busy={isLoading}
        {...props}
      >
        <span className={styles.content}>
          {icon && iconPosition === 'left' && (
            <span className={styles.icon}>{icon}</span>
          )}
          <span className={styles.label}>{children}</span>
          {icon && iconPosition === 'right' && (
            <span className={styles.icon}>{icon}</span>
          )}
        </span>
        {isLoading && <span className={styles.spinner} />}
      </button>
    );
  }
);

Button.displayName = 'Button';
