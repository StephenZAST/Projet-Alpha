import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table from './Tablecontainer';
import styles from './style/ClientManagement.module.css';

interface Client {
  id: string;
  name: string;
  email: string;
  phoneNumber: string;
}

const ClientManagement: React.FC = () => {
  const [clients, setClients] = useState<Client[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchClients = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/clients');
        setClients(response.data);
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
    fetchClients();
  }, []);

  const columns = [
    { key: 'name', label: 'Name' },
    { key: 'email', label: 'Email' },
    { key: 'phoneNumber', label: 'Phone Number' },
  ];

  return (
    <div className={styles.clientManagementContainer}>
      <h2>Client Management</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <Table data={clients} columns={columns} />
      )}
    </div>
  );
};

export default ClientManagement;
