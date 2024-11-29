/* eslint-disable @typescript-eslint/no-unused-vars */
import axios, { AxiosError } from 'axios';
import { AppError } from '../utils/errors';
import { auth, googleProvider } from '../config/firebase';
import { signInWithPopup } from 'firebase/auth';

const apiBaseUrl = 'https://us-central1-alpha-79c09.cloudfunctions.net/api';

class AuthService {
  async login(email: string, password: string) {
    try {
      const response = await axios.post(`${apiBaseUrl}/admin/login`, { email, password });
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
      const response = await axios.post(`${apiBaseUrl}/admin/master/create`, adminData);
      return response.data.data;
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
      
      const response = await axios.post(`${apiBaseUrl}/admin/google-auth`, {
        idToken
      });

      if (response.data.token) {
        localStorage.setItem('token', response.data.token);
        return response.data;
      }
      throw new AppError('Failed to authenticate with Google', 401, 'GOOGLE_AUTH_FAILED');
    } catch (error) {
      throw AppError.fromAxiosError(error);
    }
  }

  logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('adminRole');
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
