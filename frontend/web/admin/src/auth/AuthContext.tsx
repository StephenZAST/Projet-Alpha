import React, { createContext } from 'react';
import { AdminType } from '../dashboard/types/adminTypes';

interface AuthContextProps {
  children: React.ReactNode;
}

interface User {
  adminType: AdminType;
  // Add other user-related properties here
}

interface AuthContextValue {
  isAuthenticated: boolean;
  user: User | null;
  // Add other authentication-related properties and methods here
}

const AuthContext = createContext<AuthContextValue>({
  isAuthenticated: true, // Set to true to disable authentication
  user: null,
});

const useAuth = () => {
  return { isAuthenticated: true, user: { adminType: 'MASTER_SUPER_ADMIN' } }; // Set to true to disable authentication and provide a mock user
};

const AuthProvider: React.FC<AuthContextProps> = ({ children }) => {
  return (
    <AuthContext.Provider value={{ isAuthenticated: true, user: { adminType: 'MASTER_SUPER_ADMIN' } }}>
      {children}
    </AuthContext.Provider>
  );
};

export { AuthProvider, AuthContext, useAuth };
