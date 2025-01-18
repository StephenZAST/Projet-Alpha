import { useState, useCallback } from 'react';
import { api } from '../utils/api';
import { ENDPOINTS } from '../config/endpoints';

interface User {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  role: string;
  createdAt: string;
}

export const useUsers = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchUsers = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await api.get<User[]>(ENDPOINTS.USERS.LIST);
      setUsers(data);
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Failed to fetch users');
    } finally {
      setLoading(false);
    }
  }, []);

  const updateUser = async (id: string, userData: Partial<User>) => {
    try {
      await api.put(ENDPOINTS.USERS.UPDATE(id), userData);
      await fetchUsers();
    } catch (err: unknown) {
      throw new Error(err instanceof Error ? err.message : 'Failed to update user');
    }
  };

  const deleteUser = async (id: string) => {
    try {
      await api.delete(ENDPOINTS.USERS.DELETE(id));
      await fetchUsers();
    } catch (err: unknown) {
      throw new Error(err instanceof Error ? err.message : 'Failed to delete user');
    }
  };

  return { 
    users, 
    loading, 
    error, 
    refetch: fetchUsers,
    updateUser,
    deleteUser 
  };
};
