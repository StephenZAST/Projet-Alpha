import { colors } from '../../theme/colors';
import { Button } from './Button';

interface ErrorFallbackProps {
  error: Error;
  resetErrorBoundary: () => void;
}

export const ErrorFallback: React.FC<ErrorFallbackProps> = ({ 
  error, 
  resetErrorBoundary 
}) => {
  return (
    <div style={{
      padding: '24px',
      textAlign: 'center',
      maxWidth: '500px',
      margin: '48px auto'
    }}>
      <h2 style={{ color: colors.error }}>Something went wrong</h2>
      <pre style={{ 
        margin: '16px 0',
        padding: '16px',
        backgroundColor: colors.errorLight,
        borderRadius: '8px',
        overflow: 'auto'
      }}>
        {error.message}
      </pre>
      <Button onClick={resetErrorBoundary}>Try again</Button>
    </div>
  );
};
