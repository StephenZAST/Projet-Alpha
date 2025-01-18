import { useState, useCallback } from 'react';

export const useApiError = () => {
  const [error, setError] = useState<string | null>(null);

  const handleError = useCallback((error: Error & { response?: { data?: { message?: string } } }) => {
    const message = error.response?.data?.message || error.message || 'An error occurred';
    setError(message);
    setTimeout(() => setError(null), 5000); // Auto clear after 5s
  }, []);

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  return { error, handleError, clearError };
};
