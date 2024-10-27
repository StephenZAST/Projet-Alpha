import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const articlesApi = {
  getAll: () => api.get('/articles'),
  getById: (id: string) => api.get(`/articles/${id}`),
};

export const ordersApi = {
  create: (orderData: any) => api.post('/orders', orderData),
  getByUser: () => api.get('/orders'),
};

export const userApi = {
  login: (credentials: any) => api.post('/auth/login', credentials),
  register: (userData: any) => api.post('/auth/register', userData),
  getProfile: () => api.get('/users/profile'),
};
