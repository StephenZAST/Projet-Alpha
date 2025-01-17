import { useNavigate } from 'react-router-dom';
import { colors } from '../theme/colors';
import { Button } from '../components/common/Button';

export const Unauthorized = () => {
  const navigate = useNavigate();

  return (
    <div style={{
      height: '100vh',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      flexDirection: 'column',
      backgroundColor: colors.gray50
    }}>
      <div style={{
        backgroundColor: colors.white,
        padding: '32px',
        borderRadius: '12px',
        boxShadow: '0 4px 6px rgba(0,0,0,0.1)',
        textAlign: 'center',
        maxWidth: '400px'
      }}>
        <h1 style={{ color: colors.error, marginBottom: '16px' }}>
          Access Denied
        </h1>
        <p style={{ 
          marginBottom: '24px',
          color: colors.gray600 
        }}>
          You don't have permission to access this page
        </p>
        <Button
          onClick={() => navigate('/dashboard')}
          variant="primary"
        >
          Return to Dashboard
        </Button>
      </div>
    </div>
  );
};
