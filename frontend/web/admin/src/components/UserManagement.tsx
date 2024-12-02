import React from 'react';
import styles from './style/UserManagement.module.css';

interface UserManagementProps {
  users: string[];
  addUser: (user: string) => void;
  removeUser: (user: string) => void;
}

const UserManagement: React.FC<UserManagementProps> = ({
  users,
  addUser,
  removeUser,
}) => {
  const [newUser, setNewUser] = React.useState('');

  const handleAddUser = () => {
    addUser(newUser);
    setNewUser('');
  };

  const handleRemoveUser = (user: string) => {
    removeUser(user);
  };

  return (
    <div className={styles.userManagementContainer}>
      <h2>User Management</h2>
      <ul>
        {users.map((user) => (
          <li key={user}>
            {user}
            <button onClick={() => handleRemoveUser(user)}>Remove</button>
          </li>
        ))}
      </ul>
      <input
        type="text"
        value={newUser}
        onChange={(e) => setNewUser(e.target.value)}
        placeholder="Add new user"
      />
      <button onClick={handleAddUser}>Add User</button>
    </div>
  );
};

export default UserManagement;
