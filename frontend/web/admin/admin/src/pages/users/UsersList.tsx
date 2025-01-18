import { useState } from 'react';
import { useUsers } from '../../hooks/useUsers';
import { colors } from '../../theme/colors';
import { Button } from '../../components/common/Button';
import { DataTable } from '../../components/common/DataTable';
import { SearchBar } from '../../components/common/SearchBar';
import { LoadingSpinner } from '../../components/common/Loading';
import { Edit2, Trash2 } from 'react-feather';
import type { User } from '../../types/auth';

export const UsersList = () => {
  const { users, loading, error, deleteUser } = useUsers();
  const [searchTerm, setSearchTerm] = useState('');
  const [editingUser, setEditingUser] = useState<User | null>(null);

  const columns = [
    { 
      key: 'name',
      label: 'Name',
      render: (_: unknown, user: User) => `${user.firstName} ${user.lastName}`
    },
    { key: 'email', label: 'Email' },
    { 
      key: 'role',
      label: 'Role',
      render: (value: string) => (
        <span style={{
          padding: '4px 8px',
          borderRadius: '4px',
          backgroundColor: colors.primaryLight + '20',
          color: colors.primary,
          fontSize: '14px'
        }}>
          {value}
        </span>
      )
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (_: unknown, user: User) => (
        <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
          <Button
            variant="secondary"
            onClick={() => setEditingUser(user)}
          >
            <Edit2 size={16} />
          </Button>
          <Button
            variant="secondary"
            onClick={() => handleDelete(user.id)}
          >
            <Trash2 size={16} />
          </Button>
        </div>
      )
    }
  ];

  const handleDelete = async (userId: string) => {
    if (!window.confirm('Are you sure you want to delete this user?')) {
      return;
    }
    try {
      await deleteUser(userId);
    } catch (err) {
      console.error('Failed to delete user:', err);
      // You might want to show a toast notification here
    }
  };

  const filteredUsers = users?.filter(user => 
    user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
    `${user.firstName} ${user.lastName}`.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.role.toLowerCase().includes(searchTerm.toLowerCase())
  ) || [];

  if (loading) {
    return <LoadingSpinner />;
  }

  if (error) {
    return (
      <div style={{ 
        padding: '24px', 
        color: colors.error,
        backgroundColor: colors.errorLight,
        borderRadius: '8px',
        textAlign: 'center'
      }}>
        {error}
      </div>
    );
  }

  return (
    <div style={{ padding: '24px' }}>
      <div style={{ 
        display: 'flex', 
        justifyContent: 'space-between', 
        alignItems: 'center',
        marginBottom: '24px' 
      }}>
        <h1>Users Management</h1>
        <Button 
          variant="primary"
          onClick={() => setEditingUser({})}
        >
          Add User
        </Button>
      </div>

      <div style={{ marginBottom: '24px' }}>
        <SearchBar
          placeholder="Search users..."
          onSearch={setSearchTerm}
        />
      </div>

      <DataTable
        data={filteredUsers}
        columns={columns}
        loading={loading}
      />

      {/* TODO: Add UserForm modal component */}
      {editingUser && (
        <div>
          {/* Add your modal/form component here */}
        </div>
      )}
    </div>
  );
};