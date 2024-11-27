import React from 'react';
import Table from './Table';
import styles from './style/SupportTickets.module.css';

interface SupportTicket {
  id: string;
  subject: string;
  status: string;
}

const supportTicketData: SupportTicket[] = [
  {
    id: '1',
    subject: 'Support ticket 1',
    status: 'Open',
  },
  // ... more support ticket data
];

const SupportTickets: React.FC = () => {
  const columns = [
    { key: 'id', label: 'Ticket ID' },
    { key: 'subject', label: 'Subject' },
    { key: 'status', label: 'Status' },
  ];

  return (
    <div className={styles.supportTicketsContainer}>
      <h2>Support Tickets</h2>
      <Table data={supportTicketData} columns={columns} />
    </div>
  );
};

export default SupportTickets;
