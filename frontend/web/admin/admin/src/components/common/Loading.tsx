import { colors } from '../../theme/colors';

interface LoadingProps {
  size?: 'small' | 'medium' | 'large';
  fullscreen?: boolean;
}

export const LoadingSpinner: React.FC<LoadingProps> = ({ 
  size = 'medium',
  fullscreen = false 
}) => {
  const sizes = {
    small: 20,
    medium: 30,
    large: 40
  };

  return (
    <div style={{
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      padding: '24px',
      ...(fullscreen && {
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        backgroundColor: 'rgba(255,255,255,0.8)',
        zIndex: 9999
      })
    }}>
      <div style={{
        width: `${sizes[size]}px`,
        height: `${sizes[size]}px`,
        border: `3px solid ${colors.gray200}`,
        borderTop: `3px solid ${colors.primary}`,
        borderRadius: '50%',
        animation: 'spin 1s linear infinite'
      }} />
    </div>
  );
};

export const LoadingOverlay: React.FC = () => (
  <LoadingSpinner fullscreen size="large" />
);