import { useState, useEffect, useCallback } from 'react';
import { api } from '../utils/api';
import { AnalyticsMetrics, TimeFrame } from '../types/analytics';

export const useAnalytics = (timeframe: TimeFrame) => {
  const [data, setData] = useState<AnalyticsMetrics['data']>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await api.get<AnalyticsMetrics>(`/admin/analytics?timeframe=${timeframe}`);
      setData(response.data.data);
    } catch (err: Error) {
      setError(err.message || 'Failed to fetch analytics data');
      console.error('Analytics fetch error:', err);
    } finally {
      setLoading(false);
    }
  }, [timeframe]);

  useEffect(() => {
    fetchData();
  }, [timeframe, fetchData]);

  return { data, loading, error, refetch: fetchData };
};
