import React, { useState } from 'react';
import Datepicker, { DateValueType, DateRangeType } from 'react-tailwindcss-datepicker';
import styles from './style/AppointmentScheduling.module.css';

const AppointmentScheduling: React.FC = () => {
  const [selectedDate, setSelectedDate] = useState<DateValueType>(null);

  const handleDateChange = (selectedDate: DateValueType) => {
    setSelectedDate(selectedDate);
  };

  const formatDate = (date: DateValueType): string => {
    if (date && typeof date === 'object' && 'startDate' in date && 'endDate' in date) {
      const dateRange = date as DateRangeType;
      return `${dateRange.startDate?.toLocaleDateString()} - ${dateRange.endDate?.toLocaleDateString()}`;
    } else if (date && typeof date === 'object' && 'getTime' in date) {
      return (date as Date).toLocaleDateString();
    } else {
      return '';
    }
  };

  return (
    <div className={styles.appointmentSchedulingContainer}>
      <h2>Appointment Scheduling</h2>
      <Datepicker 
        value={selectedDate} 
        onChange={handleDateChange} 
        displayFormat="DD/MM/YYYY" 
      />
      {/* Placeholder for time slot selection */}
      <div>
        <h3>Select Time Slot</h3>
        {/* Time slot selection logic will go here */}
        {selectedDate && `Selected date: ${formatDate(selectedDate)}`}
      </div>
    </div>
  );
};

export default AppointmentScheduling;
