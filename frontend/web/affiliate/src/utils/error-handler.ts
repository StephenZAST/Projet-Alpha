import { toast } from 'react-toastify';

export const handleApiError = (error: any) => {
  const message = error.response?.data?.error || 'Une erreur est survenue';
  toast.error(message);
  return Promise.reject(error);
};
