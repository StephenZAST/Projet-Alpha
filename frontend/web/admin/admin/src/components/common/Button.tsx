import React from 'react';
import { colors } from '../../theme/colors';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary';
  isLoading?: boolean;
}

export const Button: React.FC<ButtonProps> = ({
  children,
  variant = 'primary',
  isLoading = false,
  ...props
}) => {
  return (
    <button
      style={{
        backgroundColor: variant === 'primary' ? colors.primary : colors.white,
        color: variant === 'primary' ? colors.white : colors.primary,
        border: `1px solid ${colors.primary}`,
        padding: '10px 20px',
        borderRadius: '8px',
        cursor: isLoading ? 'not-allowed' : 'pointer',
        opacity: isLoading ? 0.7 : 1,
      }}
      disabled={isLoading}
      {...props}
    >
      {isLoading ? 'Loading...' : children}
    </button>
  );
};