/**
 * 💎 GlassCard Component - Glassmorphism Effect
 * Réutilisable pour tous les cards du site
 */

import React from 'react';
import styles from './GlassCard.module.css';

interface GlassCardProps {
  children: React.ReactNode;
  className?: string;
  style?: React.CSSProperties;
  variant?: 'neutral' | 'primary' | 'success' | 'warning' | 'error';
  hasBorder?: boolean;
  hasShadow?: boolean;
  onClick?: () => void;
  hover?: boolean;
}

export const GlassCard: React.FC<GlassCardProps> = ({
  children,
  className = '',
  style,
  variant = 'neutral',
  hasBorder = true,
  hasShadow = true,
  onClick,
  hover = true,
}) => {
  const cardClass = `
    ${styles.card}
    ${styles[variant]}
    ${hasBorder ? styles.withBorder : ''}
    ${hasShadow ? styles.withShadow : ''}
    ${hover ? styles.hover : ''}
    ${onClick ? styles.clickable : ''}
    ${className}
  `.trim();

  return (
    <div
      className={cardClass}
      style={style}
      onClick={onClick}
      role={onClick ? 'button' : undefined}
      tabIndex={onClick ? 0 : undefined}
      onKeyDown={onClick ? (e) => e.key === 'Enter' && onClick() : undefined}
    >
      {children}
    </div>
  );
};
