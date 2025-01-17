import { useAuth } from '../../contexts/AuthContext';
import { colors } from '../../theme/colors';
import { Button } from '../common/Button';

export const Header = () => {
  const { logout, state } = useAuth();
  
  return (
    <header style={{
      height: '60px',
      backgroundColor: colors.white,
      borderBottom: `1px solid ${colors.gray200}`,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '0 24px'
    }}>
      <h1 style={{ fontSize: '20px', color: colors.gray800 }}>Admin Dashboard</h1>
      <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
        <span style={{ color: colors.gray600 }}>{state.user?.email}</span>
        <Button variant="secondary" onClick={logout}>Logout</Button>
      </div>
    </header>
  );
};