import React, { createContext, useContext, useState, useCallback } from 'react';
import { AdminType } from '../dashboard/types/adminTypes';
import { mockUsers, findUserByEmail } from './mockData';
import { User, AuthContextType, LoginCredentials } from './types';

interface AuthContextProps {
  children: React.ReactNode;
}

const AuthContext = createContext<AuthContextType | null>(null);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider: React.FC<AuthContextProps> = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(true); // Set to true for development
  const [user, setUser] = useState<User | null>(() => mockUsers[0]); // Use first mock user for development
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const login = useCallback(async (credentials: LoginCredentials) => {
    try {
      setLoading(true);
      setError(null);
      
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      const user = findUserByEmail(credentials.email);
      if (!user) {
        throw new Error('Invalid credentials');
      }

      setUser(user);
      setIsAuthenticated(true);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const logout = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 500));
      
      setUser(null);
      setIsAuthenticated(false);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const updateUser = useCallback(async (updates: Partial<User>) => {
    try {
      setLoading(true);
      setError(null);
      
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 500));
      
      setUser(prev => prev ? { ...prev, ...updates } : null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const value = {
    isAuthenticated,
    user,
    loading,
    error,
    login,
    logout,
    updateUser
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};

export { AuthContext };
