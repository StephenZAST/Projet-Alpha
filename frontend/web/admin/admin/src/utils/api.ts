import axios, { AxiosError } from 'axios';

const BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api';

interface ApiError {
  message: string;
  status: number;
}

interface ApiErrorResponse {
  message: string;
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
});

apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

apiClient.interceptors.response.use(
  (response) => response.data,
  (error) => {
    return handleError(error as AxiosError);
  }
);

export const api = {
  get: async <T>(endpoint: string): Promise<T> => {
    try {
      const response = await axios.get(`${BASE_URL}${endpoint}`, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`,
        },
      });
      return response.data;
    } catch (error) {
      return handleError(error as AxiosError);
    }
  },
  post: async <T, D = unknown>(endpoint: string, data: D): Promise<T> => {
    try {
      const response = await axios.post(`${BASE_URL}${endpoint}`, data, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`,
        },
      });
      return response.data;
    } catch (error) {
      return handleError(error as AxiosError);
    }
  },
  put: async <T, D = unknown>(endpoint: string, data: D): Promise<T> => {
    try {
      const response = await axios.put(`${BASE_URL}${endpoint}`, data, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`,
        },
      });
      return response.data;
    } catch (error) {
      return handleError(error as AxiosError);
    }
  },
  delete: async <T>(endpoint: string): Promise<T> => {
    try {
      const response = await axios.delete(`${BASE_URL}${endpoint}`, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`,
        },
      });
      return response.data;
    } catch (error) {
      return handleError(error as AxiosError);
    }
  },
};