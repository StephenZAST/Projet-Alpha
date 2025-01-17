import axios from 'axios';
import { handleApiError } from './error-handler';

const axiosInstance = axios.create({
  baseURL: process.env.REACT_APP_API_URL,
  withCredentials: true
});

axiosInstance.interceptors.response.use(
  (response) => response,
  handleApiError
);

export default axiosInstance;
