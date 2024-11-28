import React, { useState, useEffect } from 'react';
import axios from 'axios';
import styles from '../style/DailyOverview.module.css';

interface DailyMetric {
  label: string;
  value: number;
}

const DailyOverview: React.FC = () => {
  const [dailyMetrics, setDailyMetrics] = useState<DailyMetric[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchDailyMetrics = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/daily-overview');
        setDailyMetrics(response.data);
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
    fetchDailyMetrics();
  }, []);

  return (
    <div className={styles.dailyOverviewContainer}>
      <h2>Daily Overview</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <div className={styles.metricCards}>
          {dailyMetrics.map((metric, index) => (
            <div key={index} className={styles.metricCard}>
              <h3>{metric.label}</h3>
              <p>{metric.value}</p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default DailyOverview;
