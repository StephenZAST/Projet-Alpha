import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table from './Table';
import styles from './style/RoleManagement.module.css';

interface Role {
  id: string;
  name: string;
  description: string;
}

const RoleManagement: React.FC = () => {
  const [roles, setRoles] = useState<Role[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchRoles = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/roles');
        setRoles(response.data);
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
    fetchRoles();
  }, []);

  const columns = [
    { key: 'id', label: 'Role ID' },
    { key: 'name', label: 'Name' },
    { key: 'description', label: 'Description' },
  ];

  return (
    <div className={styles.roleManagementContainer}>
      <h2>Role Management</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <Table data={roles} columns={columns} />
      )}
    </div>
  );
};

export default RoleManagement;
