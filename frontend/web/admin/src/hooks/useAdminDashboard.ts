import { useState, useEffect } from 'react';
import { AdminRole } from '../types/admin';

export const useAdminDashboard = (role: AdminRole) => {
  const [metrics, setMetrics] = useState([]);
  const [activities, setActivities] = useState([]);
  const [alerts, setAlerts] = useState([]);
  const [companies, setCompanies] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchDashboardData = async () => {
      try {
        setLoading(true);
        
        const [metricsData, activitiesData, alertsData, companiesData] = await Promise.all([
          fetch(`/api/metrics/${role}`).then(res => res.json()),
          fetch(`/api/activities/${role}`).then(res => res.json()),
          fetch(`/api/alerts/${role}`).then(res => res.json()),
          fetch(`/api/companies/${role}`).then(res => res.json())
        ]);

        setMetrics(metricsData);
        setActivities(activitiesData);
        setAlerts(alertsData);
        setCompanies(companiesData);
      } catch (err) {
        setError(err instanceof Error ? err : new Error('Failed to fetch dashboard data'));
      } finally {
        setLoading(false);
      }
    };

    fetchDashboardData();
  }, [role]);

  return {
    metrics,
    activities,
    alerts,
    companies,
    loading,
    error
  };
};