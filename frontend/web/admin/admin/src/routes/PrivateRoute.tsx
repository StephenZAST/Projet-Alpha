
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

export const PrivateRoute = () => {
  const { state } = useAuth();

  if (state.loading) {
    return <div>Loading...</div>;
  }

  return state.isAuthenticated ? <Outlet /> : <Navigate to="/login" />;
};