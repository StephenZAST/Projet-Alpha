import axios, { AxiosError, AxiosResponse } from 'axios';
import { User, LoginResponse, LoginCredentials } from '../types/auth';

const BASE_URL = 'http://localhost:3001/api'; // Assurez-vous que le port et le chemin sont corrects

interface ApiError {
  message: string;
  status: number;
}

interface ApiErrorResponse {
  message: string;
}

interface ApiResponse<T> {
  success: boolean;
  data: T;
}

const handleError = (error: AxiosError): never => {
  const errorMessage = (error.response?.data as ApiErrorResponse)?.message || error.message;
  const status = error.response?.status || 500;
  
  if (status === 401) {
    localStorage.removeItem('token');
    window.location.href = '/login';
  }

  throw { message: errorMessage, status } as ApiError;
};

const apiClient = axios.create({
  baseURL: BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: true, // Assurez-vous que cette ligne est présente
});

apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    console.log('Request:', { 
      url: config.url, 
      method: config.method, 
      data: config.data 
    }); // Debug log
    return config;
  },
  (error) => {
    console.error('Request error:', error);
    return Promise.reject(error);
  }
);

apiClient.interceptors.response.use(
  (response: AxiosResponse<any>) => {
    console.log('Response:', response.data); // Debug log
    return response;
  },
  (error) => {
    console.error('Response error:', error.response?.data || error);
    return handleError(error as AxiosError);
  }
);

const validateLoginResponse = (response: AxiosResponse<LoginResponse>) => {
  if (!response.data?.success || !response.data?.data) {
    throw new Error('Invalid response format');
  }
  const { user, token } = response.data.data;
  if (!user || !token) {
    throw new Error('Missing user or token in response');
  }
  return response.data.data;
};

export const authApi = {
  login: async (credentials: LoginCredentials) => {
    const response = await apiClient.post<LoginResponse>('/auth/login', credentials);
    return validateLoginResponse(response);
  },
  get: async <T>(url: string): Promise<{ data: T }> => {
    const response = await apiClient.get<T>(url, {
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('token')}`,
      },
    });
    return { data: response.data };
  },
  post: async (url: string, data?: any) => {
    const response = await apiClient.post(url, data, {
      headers: {
        'Content-Type': 'application/json',
      },
    });
    return response.data;
  },
  put: async <T>(url: string, data: any): Promise<{ data: T }> => {
    const response = await apiClient.put<T>(url, data, {
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${localStorage.getItem('token')}`
      },
    });
    return { data: response.data };
  }
};

export default apiClient; // Exporter par défaut apiClient