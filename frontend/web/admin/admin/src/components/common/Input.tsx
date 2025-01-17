
import React from 'react';
import { colors } from '../../theme/colors';

interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
}

export const Input: React.FC<InputProps> = ({ label, error, ...props }) => {
  return (
    <div style={{ marginBottom: '16px' }}>
      {label && (
        <label style={{ display: 'block', marginBottom: '8px', color: colors.gray700 }}>
          {label}
        </label>
      )}
      <input
        style={{
          width: '100%',
          padding: '10px',
          border: `1px solid ${error ? colors.error : colors.gray300}`,
          borderRadius: '8px',
          outline: 'none',
        }}
        {...props}
      />
      {error && (
        <span style={{ color: colors.error, fontSize: '14px' }}>
          {error}
        </span>
      )}
    </div>
  );
};