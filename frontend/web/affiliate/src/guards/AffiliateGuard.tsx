import { Navigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';

export function AffiliateGuard({ children }: { children: React.ReactNode }) {
  const { user, isLoading } = useAuth();

  if (isLoading) {
    return <LoadingScreen />;
  }

  if (!user || user.role !== 'AFFILIATE') {
    return <Navigate to="/login" />;
  }

  return <>{children}</>;
}
