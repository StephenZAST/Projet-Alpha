import axios from 'axios';

const BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api';

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
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export const api = {
  get: <T>(endpoint: string) => apiClient.get<T, T>(endpoint),
  post: <T>(endpoint: string, data: any) => apiClient.post<T, T>(endpoint, data),
  put: <T>(endpoint: string, data: any) => apiClient.put<T, T>(endpoint, data),
  delete: <T>(endpoint: string) => apiClient.delete<T, T>(endpoint),
};