import React from 'react';
import styles from './style/TicketAnalytics.module.css';

interface TicketAnalyticsProps {
  ticketCount: number;
  ticketResolutionRate: number;
  ticketResponseTime: number;
}

const TicketAnalytics: React.FC<TicketAnalyticsProps> = ({
  ticketCount,
  ticketResolutionRate,
  ticketResponseTime,
}) => {
  return (
    <div className={styles.ticketAnalyticsContainer}>
      <h2>Ticket Analytics</h2>
      <p>Ticket Count: {ticketCount}</p>
      <p>Ticket Resolution Rate: {ticketResolutionRate}%</p>
      <p>Ticket Response Time: {ticketResponseTime} minutes</p>
    </div>
  );
};

export default TicketAnalytics;
