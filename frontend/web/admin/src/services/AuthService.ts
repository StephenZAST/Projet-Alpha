/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-unused-vars */
import axios, { AxiosError } from 'axios';
import { AppError } from '../utils/errors';
import { auth, googleProvider } from '../config/firebase';
import { signInWithPopup } from 'firebase/auth';

// Use environment variable for API URL
const apiBaseUrl = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

// Add axios default headers
axios.defaults.headers.common['Content-Type'] = 'application/json';

class AuthService {
  async login(email: string, password: string) {
    try {
      const response = await axios.post(`${apiBaseUrl}/auth/login`, { email, password });
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

      const response = await axios.post(`${apiBaseUrl}/admins/master/create`, adminData);
      
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
      
      const response = await axios.post(`${apiBaseUrl}/auth/google`, {
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
