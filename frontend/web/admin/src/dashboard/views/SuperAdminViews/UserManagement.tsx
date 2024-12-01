import React, { useState } from 'react';
import styles from './UserManagement.module.css';

interface User {
  id: string;
  name: string;
  email: string;
  role: string;
  status: 'active' | 'inactive' | 'pending';
  lastActive: string;
  department: string;
}

interface Department {
  id: string;
  name: string;
}

interface Role {
  id: string;
  name: string;
  level: number;
}

export const UserManagement: React.FC = () => {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedRole, setSelectedRole] = useState('all');
  const [selectedStatus, setSelectedStatus] = useState('all');
  const [selectedDepartment, setSelectedDepartment] = useState('all');
  const [showAddUserModal, setShowAddUserModal] = useState(false);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);

  // Mock data
  const users: User[] = [
    {
      id: '1',
      name: 'John Smith',
      email: 'john.smith@company.com',
      role: 'Admin',
      status: 'active',
      lastActive: '2024-01-15T14:30:00',
      department: 'Marketing'
    },
    {
      id: '2',
      name: 'Emma Wilson',
      email: 'emma.w@company.com',
      role: 'Editor',
      status: 'active',
      lastActive: '2024-01-15T13:45:00',
      department: 'Content'
    },
    {
      id: '3',
      name: 'Michael Brown',
      email: 'm.brown@company.com',
      role: 'Moderator',
      status: 'inactive',
      lastActive: '2024-01-14T09:20:00',
      department: 'Support'
    },
    {
      id: '4',
      name: 'Sarah Davis',
      email: 'sarah.d@company.com',
      role: 'Admin',
      status: 'pending',
      lastActive: '2024-01-15T11:15:00',
      department: 'Sales'
    }
  ];

  const departments: Department[] = [
    { id: '1', name: 'Marketing' },
    { id: '2', name: 'Content' },
    { id: '3', name: 'Support' },
    { id: '4', name: 'Sales' },
    { id: '5', name: 'Development' }
  ];

  const roles: Role[] = [
    { id: '1', name: 'Admin', level: 1 },
    { id: '2', name: 'Editor', level: 2 },
    { id: '3', name: 'Moderator', level: 3 },
    { id: '4', name: 'Viewer', level: 4 }
  ];

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active':
        return styles.statusActive;
      case 'inactive':
        return styles.statusInactive;
      case 'pending':
        return styles.statusPending;
      default:
        return '';
    }
  };

  const handleUserAction = (action: string, user: User) => {
    setSelectedUser(user);
    switch (action) {
      case 'edit':
        setShowAddUserModal(true);
        break;
      case 'delete':
        // Implement delete confirmation modal
        break;
      default:
        break;
    }
  };

  const filteredUsers = users.filter(user => {
    const matchesSearch = 
      user.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      user.email.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesRole = selectedRole === 'all' || user.role === selectedRole;
    const matchesStatus = selectedStatus === 'all' || user.status === selectedStatus;
    const matchesDepartment = selectedDepartment === 'all' || user.department === selectedDepartment;
    
    return matchesSearch && matchesRole && matchesStatus && matchesDepartment;
  });

  return (
    <div className={styles.userManagement}>
      <div className={styles.header}>
        <div className={styles.titleSection}>
          <h1 className={styles.title}>User Management</h1>
          <p className={styles.subtitle}>Manage user accounts, roles, and permissions</p>
        </div>
        <button 
          className={styles.addUserButton}
          onClick={() => {
            setSelectedUser(null);
            setShowAddUserModal(true);
          }}
        >
          <span className="material-icons">person_add</span>
          Add New User
        </button>
      </div>

      <div className={styles.filters}>
        <div className={styles.searchBar}>
          <span className="material-icons">search</span>
          <input
            type="text"
            placeholder="Search users..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
        <div className={styles.filterControls}>
          <select
            value={selectedRole}
            onChange={(e) => setSelectedRole(e.target.value)}
            className={styles.filterSelect}
          >
            <option value="all">All Roles</option>
            {roles.map(role => (
              <option key={role.id} value={role.name}>{role.name}</option>
            ))}
          </select>
          <select
            value={selectedStatus}
            onChange={(e) => setSelectedStatus(e.target.value)}
            className={styles.filterSelect}
          >
            <option value="all">All Status</option>
            <option value="active">Active</option>
            <option value="inactive">Inactive</option>
            <option value="pending">Pending</option>
          </select>
          <select
            value={selectedDepartment}
            onChange={(e) => setSelectedDepartment(e.target.value)}
            className={styles.filterSelect}
          >
            <option value="all">All Departments</option>
            {departments.map(dept => (
              <option key={dept.id} value={dept.name}>{dept.name}</option>
            ))}
          </select>
        </div>
      </div>

      <div className={styles.userList}>
        <div className={styles.userTable}>
          <div className={styles.tableHeader}>
            <div className={styles.tableCell}>User</div>
            <div className={styles.tableCell}>Role</div>
            <div className={styles.tableCell}>Department</div>
            <div className={styles.tableCell}>Status</div>
            <div className={styles.tableCell}>Last Active</div>
            <div className={styles.tableCell}>Actions</div>
          </div>
          {filteredUsers.map(user => (
            <div key={user.id} className={styles.tableRow}>
              <div className={styles.tableCell}>
                <div className={styles.userInfo}>
                  <div className={styles.userAvatar}>
                    {user.name.charAt(0)}
                  </div>
                  <div className={styles.userData}>
                    <span className={styles.userName}>{user.name}</span>
                    <span className={styles.userEmail}>{user.email}</span>
                  </div>
                </div>
              </div>
              <div className={styles.tableCell}>{user.role}</div>
              <div className={styles.tableCell}>{user.department}</div>
              <div className={styles.tableCell}>
                <span className={`${styles.status} ${getStatusColor(user.status)}`}>
                  {user.status}
                </span>
              </div>
              <div className={styles.tableCell}>
                {new Date(user.lastActive).toLocaleString()}
              </div>
              <div className={styles.tableCell}>
                <div className={styles.actions}>
                  <button
                    className={styles.actionButton}
                    onClick={() => handleUserAction('edit', user)}
                  >
                    <span className="material-icons">edit</span>
                  </button>
                  <button
                    className={styles.actionButton}
                    onClick={() => handleUserAction('delete', user)}
                  >
                    <span className="material-icons">delete</span>
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {showAddUserModal && (
        <div className={styles.modal}>
          <div className={styles.modalContent}>
            <div className={styles.modalHeader}>
              <h2>{selectedUser ? 'Edit User' : 'Add New User'}</h2>
              <button 
                className={styles.closeButton}
                onClick={() => setShowAddUserModal(false)}
              >
                <span className="material-icons">close</span>
              </button>
            </div>
            <div className={styles.modalBody}>
              <div className={styles.formGroup}>
                <label>Name</label>
                <input 
                  type="text" 
                  placeholder="Enter user name"
                  defaultValue={selectedUser?.name}
                />
              </div>
              <div className={styles.formGroup}>
                <label>Email</label>
                <input 
                  type="email" 
                  placeholder="Enter email address"
                  defaultValue={selectedUser?.email}
                />
              </div>
              <div className={styles.formGroup}>
                <label>Role</label>
                <select defaultValue={selectedUser?.role}>
                  {roles.map(role => (
                    <option key={role.id} value={role.name}>{role.name}</option>
                  ))}
                </select>
              </div>
              <div className={styles.formGroup}>
                <label>Department</label>
                <select defaultValue={selectedUser?.department}>
                  {departments.map(dept => (
                    <option key={dept.id} value={dept.name}>{dept.name}</option>
                  ))}
                </select>
              </div>
              <div className={styles.formGroup}>
                <label>Status</label>
                <select defaultValue={selectedUser?.status}>
                  <option value="active">Active</option>
                  <option value="inactive">Inactive</option>
                  <option value="pending">Pending</option>
                </select>
              </div>
            </div>
            <div className={styles.modalFooter}>
              <button 
                className={styles.cancelButton}
                onClick={() => setShowAddUserModal(false)}
              >
                Cancel
              </button>
              <button className={styles.saveButton}>
                {selectedUser ? 'Save Changes' : 'Add User'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
