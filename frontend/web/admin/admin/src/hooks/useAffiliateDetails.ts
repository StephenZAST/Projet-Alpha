import { useState, useEffect, useCallback } from 'react';
import { api } from '../utils/api';
import { ENDPOINTS } from '../config/endpoints';
import { Affiliate, AffiliateMetrics, AffiliateStatus } from '../types/affiliate';

export const useAffiliateDetails = (id: string) => {
  const [affiliate, setAffiliate] = useState<Affiliate | null>(null);
  const [metrics, setMetrics] = useState<AffiliateMetrics | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchData = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const [affiliateData, metricsData] = await Promise.all([
        api.get<Affiliate>(ENDPOINTS.AFFILIATES.DETAILS(id)),
        api.get<AffiliateMetrics>(ENDPOINTS.AFFILIATES.STATS(id))
      ]);
      setAffiliate(affiliateData);
      setMetrics(metricsData);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch affiliate details');
    } finally {
      setLoading(false);
    }
  }, [id]);

  const updateStatus = async (status: AffiliateStatus) => {
    try {
      await api.put(ENDPOINTS.AFFILIATES.UPDATE_STATUS(id), { status });
      await fetchData();
    } catch (err: any) {
      throw new Error(err.message || 'Failed to update affiliate status');
    }
  };

  useEffect(() => {
    fetchData();
  }, [id, fetchData]);

  return { 
    affiliate, 
    metrics, 
    loading, 
    error,
    updateStatus,
    refetch: fetchData 
  };
};
