/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-unused-vars */
import axios from 'axios';
import { AppError } from '../utils/errors';
import store from '../redux/store';
import { setUser, setToken, setIsLoggedIn, resetAuth } from '../redux/slices/authSlice';

// Use environment variable for API URL, with correct fallback
const apiBaseUrl = 'http://localhost:5000/api';

// Configure axios defaults
axios.defaults.headers.common['Content-Type'] = 'application/json';
axios.defaults.withCredentials = true;

// Create axios instance with default config
const axiosInstance = axios.create({
  baseURL: apiBaseUrl,
  withCredentials: true,
  headers: {
    'Content-Type': 'application/json'
  }
});

// Add response interceptor for error handling
axiosInstance.interceptors.response.use(
  response => response,
  error => {
    console.error('API Error:', error);
    if (error.response) {
      console.error('Response data:', error.response.data);
      console.error('Response status:', error.response.status);
    } else if (error.request) {
      console.error('No response received:', error.request);
    } else {
      console.error('Request setup error:', error.message);
    }
    return Promise.reject(error);
  }
);

class AuthService {
  async createMasterAdmin(adminData: {
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    phoneNumber: string;
  }) {
    try {
      if (!adminData.email || !adminData.password) {
        throw new AppError('Email and password are required', 400, 'INVALID_ADMIN_DATA');
      }

      const response = await axiosInstance.post('/admins/master/create', adminData);
      const { token, admin } = response.data.data;

      // Update Redux store
      store.dispatch(setToken(token));
      store.dispatch(setUser(admin));
      store.dispatch(setIsLoggedIn(true));

      // Set token in axios headers
      axiosInstance.defaults.headers.common['Authorization'] = `Bearer ${token}`;

      return response.data;
    } catch (error: any) {
      console.error('Create master admin error:', error);
      if (error.response) {
        throw new AppError(
          error.response.data.message || 'Failed to create master admin',
          error.response.status,
          error.response.data.code || 'CREATE_ADMIN_ERROR'
        );
      }
      throw new AppError('Network error', 500, 'NETWORK_ERROR');
    }
  }

  async login(email: string, password: string) {
    try {
      const response = await axiosInstance.post('/auth/login', { email, password });
      const { token, admin } = response.data.data;

      // Update Redux store
      store.dispatch(setToken(token));
      store.dispatch(setUser(admin));
      store.dispatch(setIsLoggedIn(true));

      // Set token in axios headers
      axiosInstance.defaults.headers.common['Authorization'] = `Bearer ${token}`;

      // Store in localStorage for persistence
      localStorage.setItem('token', token);
      localStorage.setItem('user', JSON.stringify(admin));

      return response.data;
    } catch (error: any) {
      console.error('Login error:', error);
      if (error.response) {
        throw new AppError(
          error.response.data.message || 'Login failed',
          error.response.status,
          error.response.data.code || 'LOGIN_ERROR'
        );
      }
      throw new AppError('Network error', 500, 'NETWORK_ERROR');
    }
  }

  logout() {
    // Clear Redux store
    store.dispatch(resetAuth());

    // Clear localStorage
    localStorage.removeItem('token');
    localStorage.removeItem('user');

    // Clear axios headers
    delete axiosInstance.defaults.headers.common['Authorization'];
  }

  checkAuth() {
    const token = localStorage.getItem('token');
    const user = localStorage.getItem('user');

    if (token && user) {
      // Update Redux store
      store.dispatch(setToken(token));
      store.dispatch(setUser(JSON.parse(user)));
      store.dispatch(setIsLoggedIn(true));

      // Set token in axios headers
      axiosInstance.defaults.headers.common['Authorization'] = `Bearer ${token}`;
      return true;
    }

    return false;
  }
}

export default new AuthService();
