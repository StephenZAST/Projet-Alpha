import React from 'react';
import { Calendar, momentLocalizer } from 'react-big-calendar';
import 'react-big-calendar/lib/css/react-big-calendar.css';
import moment from 'moment';
import styles from '../style/Schedule.module.css';

const Schedule: React.FC = () => {
  return (
    <div className={styles.scheduleContainer}>
      <h2>Schedule</h2>
      <Calendar
        localizer={momentLocalizer(moment)}
        defaultDate={new Date()}
        defaultView="month"
      />
    </div>
  );
};

export default Schedule;
