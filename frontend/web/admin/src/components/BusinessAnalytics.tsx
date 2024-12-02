import React from 'react';
import { Line } from 'react-chartjs-2';
import styles from './style/BusinessAnalytics.module.css';

const BusinessAnalytics: React.FC = () => {
  const data = {
    labels: ['January', 'February', 'March', 'April', 'May'],
    datasets: [
      {
        label: 'Sales',
        data: [100, 200, 300, 400, 500],
        backgroundColor: 'rgba(255, 99, 132, 0.2)',
        borderColor: 'rgba(255, 99, 132, 1)',
        borderWidth: 1,
      },
    ],
  };

  return (
    <div className={styles.businessAnalyticsContainer}>
      <h2>Business Analytics</h2>
      <Line data={data} />
    </div>
  );
};

export default BusinessAnalytics;
