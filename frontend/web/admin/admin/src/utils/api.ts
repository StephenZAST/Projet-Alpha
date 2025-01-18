import axios, { AxiosError } from 'axios';

const BASE_URL = 'http://localhost:3001/api'; // Assurez-vous que le port et le chemin sont corrects

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
  withCredentials: true,
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

export default apiClient; // Exporter par défaut apiClient