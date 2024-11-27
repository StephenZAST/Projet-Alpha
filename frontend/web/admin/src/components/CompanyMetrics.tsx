import React, { useState, useEffect } from 'react';
import axios from 'axios';
import styles from './style/CompanyMetrics.module.css';

interface RevenueData {
  totalRevenue: number;
  periodRevenue: number;
  orderCount: number;
  averageOrderValue: number;
}

const CompanyMetrics: React.FC = () => {
  const [revenueData, setRevenueData] = useState<RevenueData | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchRevenueData = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/analytics/revenue', {
          params: {
            startDate: '2023-12-19',
            endDate: '2023-12-25',
          },
        });
        setRevenueData(response.data);
      } catch (error) {
        if (error instanceof Error) {
          setError(error);
        } else {
          setError(new Error('Unknown error'));
        }
      } finally {
        setLoading(false);
      }
    };
    fetchRevenueData();
  }, []);

  return (
    <div className={styles.companyMetricsContainer}>
      <h2>Company Metrics</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : revenueData ? (
        <div>
          <h3>Revenue Metrics</h3>
          <p>Total Revenue: {revenueData.totalRevenue}</p>
          <p>Period Revenue: {revenueData.periodRevenue}</p>
          <p>Order Count: {revenueData.orderCount}</p>
          <p>Average Order Value: {revenueData.averageOrderValue}</p>
        </div>
      ) : null}
    </div>
  );
};

export default CompanyMetrics;
