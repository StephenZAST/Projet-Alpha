import { useState } from 'react';
import { useUsers } from '../../hooks/useUsers';
import { colors } from '../../theme/colors';
import { Button } from '../../components/common/Button';

export const UsersList = () => {
  const { users, loading, error, updateUser, deleteUser } = useUsers();
  const [selectedUser, setSelectedUser] = useState(null);

  if (loading) {
    return <div style={{ padding: '24px' }}>Loading users...</div>;
  }

  if (error) {
    return (
      <div style={{ 
        padding: '24px', 
        color: colors.error 
      }}>
        Error loading users: {error}
      </div>
    );
  }

  return (
    <div style={{ padding: '24px' }}>
      <div style={{ 
        display: 'flex', 
        justifyContent: 'space-between', 
        marginBottom: '24px' 
      }}>
        <h1>Users Management</h1>
        <Button variant="primary">Add User</Button>
      </div>

      <div style={{ 
        backgroundColor: colors.white,
        borderRadius: '12px',
        padding: '24px',
        boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
      }}>
        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead>
            <tr>
              <th style={{ textAlign: 'left', padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>Name</th>
              <th style={{ textAlign: 'left', padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>Email</th>
              <th style={{ textAlign: 'left', padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>Role</th>
              <th style={{ textAlign: 'right', padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {users.map(user => (
              <tr key={user.id}>
                <td style={{ padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>
                  {user.firstName} {user.lastName}
                </td>
                <td style={{ padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>
                  {user.email}
                </td>
                <td style={{ padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>
                  <span style={{
                    padding: '4px 8px',
                    borderRadius: '4px',
                    backgroundColor: colors.primaryLight + '20',
                    color: colors.primary,
                    fontSize: '14px'
                  }}>
                    {user.role}
                  </span>
                </td>
                <td style={{ 
                  padding: '12px', 
                  borderBottom: `1px solid ${colors.gray200}`,
                  textAlign: 'right'
                }}>
                  <Button 
                    variant="secondary" 
                    style={{ marginRight: '8px' }}
                    onClick={() => setSelectedUser(user)}
                  >
                    Edit
                  </Button>
                  <Button 
                    variant="secondary"
                    onClick={() => {
                      if (window.confirm('Are you sure you want to delete this user?')) {
                        deleteUser(user.id);
                      }
                    }}
                  >
                    Delete
                  </Button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};