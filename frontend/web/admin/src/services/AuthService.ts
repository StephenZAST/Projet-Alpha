/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-unused-vars */
import axios, { AxiosError } from 'axios';
import { AppError } from '../utils/errors';
import { auth, googleProvider } from '../config/firebase';
import { signInWithPopup } from 'firebase/auth';

// Use environment variable for API URL
const apiBaseUrl = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

// Configure axios defaults
axios.defaults.headers.common['Content-Type'] = 'application/json';
axios.defaults.withCredentials = true; // Enable credentials

// Create axios instance with default config
const axiosInstance = axios.create({
  baseURL: apiBaseUrl,
  withCredentials: true,
  headers: {
    'Content-Type': 'application/json',
    'X-Requested-With': 'XMLHttpRequest'
  }
});

// Add response interceptor for error handling
axiosInstance.interceptors.response.use(
  response => response,
  error => {
    console.error('API Error:', error);
    if (error.response) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx
      console.error('Response data:', error.response.data);
      console.error('Response status:', error.response.status);
    } else if (error.request) {
      // The request was made but no response was received
      console.error('No response received:', error.request);
    } else {
      // Something happened in setting up the request that triggered an Error
      console.error('Request setup error:', error.message);
    }
    return Promise.reject(error);
  }
);

class AuthService {
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
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      throw AppError.fromAxiosError(error);
    }
  }

  async createMasterAdmin(adminData: {
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    phoneNumber: string;
  }) {
    try {
      // Add error handling for required fields
      if (!adminData.email || !adminData.password) {
        throw new AppError('Email and password are required', 400, 'INVALID_ADMIN_DATA');
      }

      const response = await axiosInstance.post('/admins/master/create', adminData);
      
      if (response.data.success) {
        return response.data.data;
      } else {
        throw new AppError(
          response.data.message || 'Failed to create master admin',
          response.data.statusCode || 400,
          response.data.code || 'CREATION_FAILED'
        );
      }
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      throw AppError.fromAxiosError(error);
    }
  }

  async signInWithGoogle(): Promise<any> {
    try {
      const result = await signInWithPopup(auth, googleProvider);
      const idToken = await result.user.getIdToken();
      
      const response = await axiosInstance.post('/auth/google', {
        idToken
      });

      if (response.data.success) {
        const { token, user } = response.data.data;
        localStorage.setItem('token', token);
        localStorage.setItem('adminRole', user.role);
        return user;
      }
      throw new AppError('Failed to authenticate with Google', 401, 'GOOGLE_AUTH_FAILED');
    } catch (error) {
      throw AppError.fromAxiosError(error);
    }
  }

  logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('adminRole');
    auth.signOut(); // Sign out from Firebase as well
  }

  getCurrentUser() {
    const token = localStorage.getItem('token');
    const role = localStorage.getItem('adminRole');
    if (token && role) {
      return { token, role };
    }
    return null;
  }

  isAuthenticated() {
    return !!localStorage.getItem('token');
  }
}

export default new AuthService();
