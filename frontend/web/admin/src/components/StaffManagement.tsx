import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table from './Table';
import styles from './style/StaffManagement.module.css';

interface StaffMember {
  id: string;
  name: string;
  role: string;
}

const StaffManagement: React.FC = () => {
  const [staffMembers, setStaffMembers] = useState<StaffMember[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchStaffMembers = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/staff-members');
        setStaffMembers(response.data);
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
    fetchStaffMembers();
  }, []);

  const columns = [
    { key: 'id', label: 'Staff ID' },
    { key: 'name', label: 'Name' },
    { key: 'role', label: 'Role' },
  ];

  return (
    <div className={styles.staffManagementContainer}>
      <h2>Staff Management</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <Table data={staffMembers} columns={columns} />
      )}
    </div>
  );
};

export default StaffManagement;
