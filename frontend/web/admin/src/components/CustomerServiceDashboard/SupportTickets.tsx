import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table from '../Tablecontainer';
import styles from '../style/SupportTickets.module.css';

interface SupportTicket {
  id: string;
  subject: string;
  status: string;
}

const SupportTickets: React.FC = () => {
  const [supportTickets, setSupportTickets] = useState<SupportTicket[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchSupportTickets = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/support-tickets');
        setSupportTickets(response.data);
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
    fetchSupportTickets();
  }, []);

  const columns = [
    { key: 'id', label: 'Ticket ID' },
    { key: 'subject', label: 'Subject' },
    { key: 'status', label: 'Status' },
  ];

  return (
    <div className={styles.supportTicketsContainer}>
      <h2>Support Tickets</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <Table data={supportTickets} columns={columns} />
      )}
    </div>
  );
};

export default SupportTickets;
