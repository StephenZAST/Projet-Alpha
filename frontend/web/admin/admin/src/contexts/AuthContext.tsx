import { createContext, useReducer, useEffect, useCallback } from 'react';
import { api } from '../utils/api';
import { ENDPOINTS } from '../config/endpoints';
import type { User } from '../types/auth';

interface AuthState {
  user: User | null;
  token: string | null;
  loading: boolean;
  error: string | null;
  isAuthenticated: boolean;
}

interface LoginCredentials {
  email: string;
  password: string;
}

type AuthAction =
  | { type: 'LOGIN_SUCCESS'; payload: { user: User; token: string } }
  | { type: 'LOGIN_FAIL'; payload: string }
  | { type: 'LOGOUT' }
  | { type: 'SET_LOADING'; payload: boolean }
  | { type: 'CLEAR_ERROR' };

interface AuthContextType {
  state: AuthState;
  login: (credentials: LoginCredentials) => Promise<void>;
  logout: () => void;
  clearError: () => void;
  updateUserProfile: (data: Partial<User>) => Promise<void>;
}

const initialState: AuthState = {
  user: null,
  token: localStorage.getItem('token'),
  loading: true,
  error: null,
  isAuthenticated: false
};

const AuthContext = createContext<AuthContextType>({
  state: initialState,
  login: async () => {},
  logout: () => {},
  clearError: () => {},
  updateUserProfile: async () => {}
});

const authReducer = (state: AuthState, action: AuthAction): AuthState => {
  switch (action.type) {
    case 'LOGIN_SUCCESS':
      return {
        ...state,
        user: action.payload.user,
        token: action.payload.token,
        loading: false,
        error: null,
        isAuthenticated: true
      };
    case 'LOGIN_FAIL':
      return {
        ...state,
        user: null,
        token: null,
        loading: false,
        error: action.payload,
        isAuthenticated: false
      };
    case 'LOGOUT':
      return {
        ...state,
        user: null,
        token: null,
        loading: false,
        error: null,
        isAuthenticated: false
      };
    case 'SET_LOADING':
      return {
        ...state,
        loading: action.payload
      };
    case 'CLEAR_ERROR':
      return {
        ...state,
        error: null
      };
    default:
      return state;
  }
};

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [state, dispatch] = useReducer(authReducer, initialState);

  const checkAuth = useCallback(async () => {
    const token = localStorage.getItem('token');
    if (!token) {
      dispatch({ type: 'SET_LOADING', payload: false });
      return;
    }

    try {
      const userData = await api.get<User>(ENDPOINTS.AUTH.ME);
      dispatch({
        type: 'LOGIN_SUCCESS',
        payload: { user: userData, token }
      });
    } catch (error) {
      localStorage.removeItem('token');
      dispatch({ type: 'SET_LOADING', payload: false });
      dispatch({ type: 'LOGIN_FAIL', payload: error instanceof Error ? error.message : 'Session expired' });
    }
  }, []);

  useEffect(() => {
    checkAuth();
  }, [checkAuth]);

  const login = async (credentials: LoginCredentials) => {
    try {
      dispatch({ type: 'SET_LOADING', payload: true });
      const response = await api.post(ENDPOINTS.AUTH.LOGIN, credentials);
      localStorage.setItem('token', response.token);
      dispatch({
        type: 'LOGIN_SUCCESS',
        payload: { user: response.user, token: response.token }
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Login failed';
      dispatch({ type: 'LOGIN_FAIL', payload: message });
      throw error;
    }
  };

  const logout = useCallback(() => {
    localStorage.removeItem('token');
    dispatch({ type: 'LOGOUT' });
  }, []);

  const clearError = useCallback(() => {
    dispatch({ type: 'CLEAR_ERROR' });
  }, []);

  const updateUserProfile = async (data: Partial<User>) => {
    try {
      const updatedUser = await api.put<User>(ENDPOINTS.AUTH.UPDATE_PROFILE, data);
      dispatch({
        type: 'LOGIN_SUCCESS',
        payload: { user: updatedUser, token: state.token! }
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Profile update failed';
      dispatch({ type: 'LOGIN_FAIL', payload: message });
      throw error;
    }
  };

  return (
    <AuthContext.Provider 
      value={{ 
        state, 
        login, 
        logout, 
        clearError,
        updateUserProfile 
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export default AuthContext;
