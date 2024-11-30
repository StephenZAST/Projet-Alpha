/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-unused-vars */
import axios from 'axios';
import { AppError } from '../utils/errors';

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

      console.log('Sending request to:', `${apiBaseUrl}/admins/master/create`);
      console.log('Admin data:', adminData);

      const response = await axiosInstance.post('/admins/master/create', adminData);
      
      console.log('Response:', response.data);

      if (response.data.success) {
        return response.data.data;
      } else {
        throw new AppError(
          response.data.message || 'Failed to create master admin',
          response.data.statusCode || 400,
          response.data.code || 'CREATION_FAILED'
        );
      }
    } catch (error: any) {
      console.error('Error creating master admin:', error);
      
      if (error instanceof AppError) {
        throw error;
      }

      if (axios.isAxiosError(error)) {
        const message = error.response?.data?.message || 'Failed to create master admin';
        const statusCode = error.response?.status || 500;
        throw new AppError(message, statusCode, 'API_ERROR');
      }

      throw new AppError('An unexpected error occurred', 500, 'UNKNOWN_ERROR');
    }
  }

  async login(email: string, password: string) {
    try {
      const response = await axiosInstance.post('/auth/login', { email, password });
      if (response.data.success) {
        const { token, admin } = response.data.data;
        localStorage.setItem('token', token);
        localStorage.setItem('adminRole', admin.role);
        return admin;
      } else {
        throw new AppError(
          response.data.message || 'Login failed',
          response.data.statusCode || 400,
          response.data.code || 'UNAUTHORIZED'
        );
      }
    } catch (error: any) {
      if (error instanceof AppError) {
        throw error;
      }
      throw new AppError(error.message || 'Login failed', 400, 'LOGIN_FAILED');
    }
  }

  logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('adminRole');
  }

  isAuthenticated() {
    return !!localStorage.getItem('token');
  }

  getAdminRole() {
    return localStorage.getItem('adminRole');
  }
}

export default new AuthService();
