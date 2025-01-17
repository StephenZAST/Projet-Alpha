import { useState, useEffect, useCallback } from 'react';
import { api } from '../utils/api';
import { ENDPOINTS } from '../config/endpoints';

export interface DashboardStats {
  orders: number;
  revenue: number;
  users: number;
  affiliates: number;
}

export interface UseAdminReturn {
  stats: DashboardStats | null;
  orders: any[];
  loading: boolean;
  error: string | null;
  refetchStats: () => Promise<void>;
  createService: (data: any) => Promise<void>;
  updateService: (id: string, data: any) => Promise<void>;
  deleteService: (id: string) => Promise<void>;
}

export const useAdmin = (): UseAdminReturn => {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [orders, setOrders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchStats = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      
      const [statsData, ordersData] = await Promise.all([
        api.get<DashboardStats>(ENDPOINTS.ADMIN.STATS),
        api.get<any[]>(ENDPOINTS.ADMIN.ORDERS)
      ]);
      
      setStats(statsData);
      setOrders(ordersData);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Failed to load dashboard data');
      console.error('Dashboard data fetch error:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  const createService = async (data: any) => {
    try {
      await api.post(ENDPOINTS.SERVICES.CREATE, data);
      await fetchStats();
    } catch (err: any) {
      throw new Error(err.message);
    }
  };

  const updateService = async (id: string, data: any) => {
    try {
      await api.put(ENDPOINTS.SERVICES.UPDATE(id), data);
      await fetchStats();
    } catch (err: any) {
      throw new Error(err.message);
    }
  };

  const deleteService = async (id: string) => {
    try {
      await api.delete(ENDPOINTS.SERVICES.DELETE(id));
      await fetchStats();
    } catch (err: any) {
      throw new Error(err.message);
    }
  };

  useEffect(() => {
    fetchStats();
  }, [fetchStats]);

  return {
    stats,
    orders,
    loading,
    error,
    refetchStats: fetchStats,
    createService,
    updateService,
    deleteService
  };
};
