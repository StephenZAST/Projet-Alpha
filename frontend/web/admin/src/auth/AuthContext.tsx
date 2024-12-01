import React, { createContext } from 'react';

interface AuthContextProps {
  children: React.ReactNode;
}

interface AuthContextValue {
  isAuthenticated: boolean;
  // Add other authentication-related properties and methods here
}

const AuthContext = createContext<AuthContextValue>({
  isAuthenticated: true, // Set to true to disable authentication
});

const useAuth = () => {
  return { isAuthenticated: true }; // Set to true to disable authentication
};

const AuthProvider: React.FC<AuthContextProps> = ({ children }) => {
  return (
    <AuthContext.Provider value={{ isAuthenticated: true }}>
      {children}
    </AuthContext.Provider>
  );
};

export { AuthProvider, AuthContext, useAuth };
