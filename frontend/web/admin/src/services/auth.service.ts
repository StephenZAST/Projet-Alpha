import axios from 'axios';
import { User } from '../types/user';
import { createAuthRefreshInterceptor } from 'axios-auth-refresh';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:3000/api';

// Create axios instance
const axiosInstance = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add token to requests
axiosInstance.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Refresh token logic
const refreshAuthLogic = async (failedRequest: any) => {
  const refreshToken = localStorage.getItem('refreshToken');
  try {
    const response = await axios.post(`${API_URL}/auth/refresh`, {
      refreshToken,
    });
    const { token } = response.data;
    localStorage.setItem('token', token);
    failedRequest.response.config.headers.Authorization = `Bearer ${token}`;
    return Promise.resolve();
  } catch (error) {
    localStorage.removeItem('token');
    localStorage.removeItem('refreshToken');
    window.location.href = '/login';
    return Promise.reject(error);
  }
};

// Add refresh token interceptor
createAuthRefreshInterceptor(axiosInstance, refreshAuthLogic);

export const AuthService = {
  api: axiosInstance,

  async login(credentials: { email: string; password: string }) {
    const response = await axiosInstance.post('/auth/login', credentials);
    return response.data;
  },

  async logout() {
    const response = await axiosInstance.post('/auth/logout');
    return response.data;
  },

  async getCurrentUser(): Promise<User> {
    const response = await axiosInstance.get('/auth/me');
    return response.data;
  },

  async refreshToken(refreshToken: string) {
    const response = await axios.post(`${API_URL}/auth/refresh`, {
      refreshToken,
    });
    return response.data;
  },

  async forgotPassword(email: string): Promise<void> {
    await axiosInstance.post('/auth/forgot-password', { email });
  },

  async resetPassword(token: string, newPassword: string): Promise<void> {
    await axiosInstance.post('/auth/reset-password', {
      token,
      newPassword,
    });
  },
};

export default AuthService;
