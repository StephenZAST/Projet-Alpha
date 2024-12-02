import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table from '../Tablecontainer';
import styles from '../style/InvoiceManagement.module.css';

interface Invoice {
  id: string;
  customerName: string;
  date: string;
}

const InvoiceManagement: React.FC = () => {
  const [invoices, setInvoices] = useState<Invoice[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchInvoices = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/invoices');
        setInvoices(response.data);
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
    fetchInvoices();
  }, []);

  const columns = [
    { key: 'id', label: 'Invoice ID' },
    { key: 'customerName', label: 'Customer Name' },
    { key: 'date', label: 'Date' },
  ];

  return (
    <div className={styles.invoiceManagementContainer}>
      <h2>Invoice Management</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <Table data={invoices} columns={columns} />
      )}
    </div>
  );
};

export default InvoiceManagement;
