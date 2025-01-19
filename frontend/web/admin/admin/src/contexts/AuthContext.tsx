import { createContext, useReducer, useEffect, useCallback, useContext } from 'react';
import { authApi } from '../utils/api';
import { ENDPOINTS } from '../constants/endpoints';
import { User, AuthState, LoginCredentials, AuthAction } from '../types/auth';

const initialState: AuthState = {
  user: null,
  token: localStorage.getItem('token'),
  isAuthenticated: false,
  loading: true,
  error: null
};

const AuthContext = createContext<{
  state: AuthState;
  login: (credentials: LoginCredentials) => Promise<void>;
  logout: () => Promise<void>;
  updateProfile: (data: Partial<User>) => Promise<void>;
} | null>(null);

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
    case 'UPDATE_PROFILE_SUCCESS':
      return {
        ...state,
        user: action.payload,
        error: null
      };
    case 'UPDATE_PROFILE_FAIL':
      return {
        ...state,
        error: action.payload
      };
    default:
      return state;
  }
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
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
      const { data: userData } = await authApi.get<User>(ENDPOINTS.AUTH.ME);
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
      console.log('Sending credentials:', credentials);

      const { user, token } = await authApi.login(credentials);
      console.log('Extracted data:', { user, token });

      localStorage.setItem('token', token);
      console.log('Token stored in localStorage:', localStorage.getItem('token'));

      dispatch({
        type: 'LOGIN_SUCCESS',
        payload: { user, token }
      });
      console.log('Auth state after login:', state);
    } catch (error) {
      console.error('Login error details:', error);
      const message = error instanceof Error ? error.message : 'Login failed';
      dispatch({ type: 'LOGIN_FAIL', payload: message });
      throw error;
    }
  };

  const logout = useCallback(async () => {
    try {
      await authApi.post(ENDPOINTS.AUTH.LOGOUT);
      localStorage.removeItem('token');
      dispatch({ type: 'LOGOUT' });
    } catch (error) {
      console.error('Logout error:', error);
    }
  }, []);

  const updateProfile = async (data: Partial<User>) => {
    try {
      const { data: updatedUser } = await authApi.put<User>(ENDPOINTS.AUTH.UPDATE_PROFILE, data);
      dispatch({
        type: 'UPDATE_PROFILE_SUCCESS',
        payload: updatedUser
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Profile update failed';
      dispatch({ type: 'UPDATE_PROFILE_FAIL', payload: message });
      throw error;
    }
  };

  return (
    <AuthContext.Provider 
      value={{ 
        state, 
        login, 
        logout, 
        updateProfile 
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export default AuthContext;