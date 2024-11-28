import React from 'react';
import Table from '../Table';
import styles from '../style/AdminTable.module.css';

interface Admin {
  id: string;
  name: string;
  email: string;
  role: string;
  status: 'active' | 'inactive';
}

const adminData: Admin[] = [
  {
    id: '1',
    name: 'John Doe',
    email: 'john.doe@example.com',
    role: 'Super Admin',
    status: 'active',
  },
  // ... more admin data
];

const AdminTable: React.FC = () => {
  const columns = [
    { key: 'name', label: 'Name' },
    { key: 'email', label: 'Email' },
    { key: 'role', label: 'Role' },
    {
      key: 'status',
      label: 'Status',
      render: (item: Admin) => (
        <span className={`${styles.status} ${styles[item.status]}`}>
          {item.status}
        </span>
      ),
    },
  ];

  return (
    <div className={styles.adminTableContainer}>
      <Table data={adminData} columns={columns} />
    </div>
  );
};

export default AdminTable;
