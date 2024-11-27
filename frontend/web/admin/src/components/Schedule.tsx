import React from 'react';
import { Calendar } from 'react-big-calendar';
import styles from './style/Schedule.module.css';

const Schedule: React.FC = () => {
  return (
    <div className={styles.scheduleContainer}>
      <h2>Schedule</h2>
      <Calendar />
    </div>
  );
};

export default Schedule;
