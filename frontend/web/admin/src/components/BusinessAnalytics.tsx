import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Chart } from '@shadcn/ui/chart';
import styles from './style/BusinessAnalytics.module.css';

const BusinessAnalytics: React.FC = () => {
  const [data, setData] = useState([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await axios.get('/api/business-analytics');
        setData(response.data);
      } catch (error) {
        console.error(error);
      }
    };
    fetchData();
  }, []);

  return (
    <div className={styles.businessAnalyticsContainer}>
      <h2>Business Analytics</h2>
      <Chart data={data} />
    </div>
  );
};

export default BusinessAnalytics;
