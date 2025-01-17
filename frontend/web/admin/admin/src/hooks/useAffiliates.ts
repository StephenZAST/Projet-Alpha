import { useState, useCallback } from 'react';
import { api } from '../utils/api';
import { ENDPOINTS } from '../config/endpoints';
import { Affiliate, AffiliateStatus } from '../types/affiliate';

export const useAffiliates = () => {
  const [affiliates, setAffiliates] = useState<Affiliate[]>([]);
  const [selectedAffiliate, setSelectedAffiliate] = useState<Affiliate | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchAffiliates = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await api.get<Affiliate[]>(ENDPOINTS.AFFILIATES.LIST);
      setAffiliates(data);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch affiliates');
    } finally {
      setLoading(false);
    }
  }, []);

  const updateAffiliateStatus = async (id: string, status: AffiliateStatus) => {
    try {
      await api.put(ENDPOINTS.AFFILIATES.UPDATE_STATUS(id), { status });
      await fetchAffiliates();
    } catch (err: any) {
      throw new Error(err.message || 'Failed to update affiliate status');
    }
  };

  const getAffiliateDetails = async (id: string) => {
    try {
      setLoading(true);
      const [details, stats] = await Promise.all([
        api.get<Affiliate>(ENDPOINTS.AFFILIATES.DETAILS(id)),
        api.get(ENDPOINTS.AFFILIATES.STATS(id))
      ]);
      setSelectedAffiliate({ ...details, ...stats });
      return { ...details, ...stats };
    } catch (err: any) {
      throw new Error(err.message || 'Failed to fetch affiliate details');
    } finally {
      setLoading(false);
    }
  };

  return {
    affiliates,
    selectedAffiliate,
    loading,
    error,
    fetchAffiliates,
    updateAffiliateStatus,
    getAffiliateDetails
  };
};
