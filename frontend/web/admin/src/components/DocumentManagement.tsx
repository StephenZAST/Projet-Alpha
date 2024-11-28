import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table from './Tablecontainer';
import styles from './style/DocumentManagement.module.css';

interface Document {
  id: string;
  name: string;
  uploadDate: string;
}

const DocumentManagement: React.FC = () => {
  const [documents, setDocuments] = useState<Document[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchDocuments = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/documents');
        setDocuments(response.data);
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
    fetchDocuments();
  }, []);

  const columns = [
    { key: 'id', label: 'Document ID' },
    { key: 'name', label: 'Name' },
    { key: 'uploadDate', label: 'Upload Date' },
  ];

  return (
    <div className={styles.documentManagementContainer}>
      <h2>Document Management</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <Table data={documents} columns={columns} />
      )}
    </div>
  );
};

export default DocumentManagement;
