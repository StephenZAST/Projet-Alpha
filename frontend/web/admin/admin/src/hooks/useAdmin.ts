import { useState, useEffect, useCallback } from 'react';
import { api } from '../utils/api';
import { ENDPOINTS } from '../config/endpoints';
import type { Service, Article, User, AffiliateProfile } from '../types/models';

interface DashboardStats {
  orders: {
    total: number;
    pending: number;
    processing: number;
    completed: number;
  };
  revenue: {
    total: number;
    monthly: number;
    daily: number;
  };
  users: {
    total: number;
    active: number;
    new: number;
  };
  affiliates: {
    total: number;
    active: number;
    pending: number;
  };
}

interface AdminData {
  services: Service[];
  articles: Article[];
  users: User[];
  affiliates: AffiliateProfile[];
}

export const useAdmin = () => {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [adminData, setAdminData] = useState<AdminData>({
    services: [],
    articles: [],
    users: [],
    affiliates: []
  });
  const [loading, setLoading] = useState<Record<string, boolean>>({
    stats: false,
    services: false,
    articles: false,
    users: false,
    affiliates: false
  });
  const [error, setError] = useState<Record<string, string | null>>({
    stats: null,
    services: null,
    articles: null,
    users: null,
    affiliates: null
  });

  const fetchStats = useCallback(async () => {
    setLoading(prev => ({ ...prev, stats: true }));
    try {
      const data = await api.get<DashboardStats>(ENDPOINTS.ADMIN.STATS);
      setStats(data);
      setError(prev => ({ ...prev, stats: null }));
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Failed to fetch stats';
      setError(prev => ({ ...prev, stats: message }));
    } finally {
      setLoading(prev => ({ ...prev, stats: false }));
    }
  }, []);

  const fetchEntities = useCallback(async <T extends keyof AdminData>(
    entity: T,
    endpoint: string
  ) => {
    setLoading(prev => ({ ...prev, [entity]: true }));
    try {
      const data = await api.get<AdminData[T]>(endpoint);
      setAdminData(prev => ({ ...prev, [entity]: data }));
      setError(prev => ({ ...prev, [entity]: null }));
    } catch (err) {
      const message = err instanceof Error ? err.message : `Failed to fetch ${entity}`;
      setError(prev => ({ ...prev, [entity]: message }));
    } finally {
      setLoading(prev => ({ ...prev, [entity]: false }));
    }
  }, []);

  const updateEntity = useCallback(async <T extends keyof AdminData>(
    entity: T,
    id: string,
    data: Partial<AdminData[T][number]>
  ) => {
    try {
      const endpoint = ENDPOINTS[entity.toUpperCase() as keyof typeof ENDPOINTS].UPDATE(id);
      await api.put(endpoint, data);
      await fetchEntities(entity, ENDPOINTS[entity.toUpperCase() as keyof typeof ENDPOINTS].LIST);
    } catch (err) {
      const message = err instanceof Error ? err.message : `Failed to update ${entity}`;
      throw new Error(message);
    }
  }, [fetchEntities]);

  const deleteEntity = useCallback(async <T extends keyof AdminData>(
    entity: T,
    id: string
  ) => {
    try {
      const endpoint = ENDPOINTS[entity.toUpperCase() as keyof typeof ENDPOINTS].DELETE(id);
      await api.delete(endpoint);
      await fetchEntities(entity, ENDPOINTS[entity.toUpperCase() as keyof typeof ENDPOINTS].LIST);
    } catch (err) {
      const message = err instanceof Error ? err.message : `Failed to delete ${entity}`;
      throw new Error(message);
    }
  }, [fetchEntities]);

  const createEntity = useCallback(async <T extends keyof AdminData>(
    entity: T,
    data: Omit<AdminData[T][number], 'id'>
  ) => {
    try {
      const endpoint = ENDPOINTS[entity.toUpperCase() as keyof typeof ENDPOINTS].CREATE;
      await api.post(endpoint, data);
      await fetchEntities(entity, ENDPOINTS[entity.toUpperCase() as keyof typeof ENDPOINTS].LIST);
    } catch (err) {
      const message = err instanceof Error ? err.message : `Failed to create ${entity}`;
      throw new Error(message);
    }
  }, [fetchEntities]);

  useEffect(() => {
    fetchStats();
    fetchEntities('services', ENDPOINTS.SERVICES.LIST);
    fetchEntities('articles', ENDPOINTS.ARTICLES.LIST);
    fetchEntities('users', ENDPOINTS.USERS.LIST);
    fetchEntities('affiliates', ENDPOINTS.ADMIN.AFFILIATES);
  }, [fetchStats, fetchEntities]);

  return {
    stats,
    data: adminData,
    loading,
    error,
    actions: {
      refetchStats: fetchStats,
      refetchEntity: fetchEntities,
      create: createEntity,
      update: updateEntity,
      delete: deleteEntity
    },
    isLoading: Object.values(loading).some(Boolean),
    hasErrors: Object.values(error).some(Boolean)
  };
};
