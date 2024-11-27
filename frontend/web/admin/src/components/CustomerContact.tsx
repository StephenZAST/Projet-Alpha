import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table from './Table';
import styles from './style/CustomerContact.module.css';

interface Customer {
  id: string;
  name: string;
  email: string;
  phoneNumber: string;
}

const CustomerContact: React.FC = () => {
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchCustomers = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/customers');
        setCustomers(response.data);
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
    fetchCustomers();
  }, []);

  const columns = [
    { key: 'name', label: 'Name' },
    { key: 'email', label: 'Email' },
    { key: 'phoneNumber', label: 'Phone Number' },
  ];

  return (
    <div className={styles.customerContactContainer}>
      <h2>Customer Contact</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <Table data={customers} columns={columns} />
      )}
    </div>
  );
};

export default CustomerContact;
