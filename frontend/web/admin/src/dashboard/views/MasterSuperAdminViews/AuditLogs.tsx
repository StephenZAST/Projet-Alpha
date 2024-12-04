import React, { useState } from 'react';
import styles from './AuditLogs.module.css';

interface AuditLog {
  id: string;
  timestamp: string;
  user: string;
  action: string;
  details: string;
  ipAddress: string;
  status: 'success' | 'warning' | 'error';
  category: 'security' | 'system' | 'user' | 'data';
}

export const AuditLogs: React.FC = () => {
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [selectedStatus, setSelectedStatus] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState<string>('');

  // Mock audit logs data
  const mockAuditLogs: AuditLog[] = [
    {
      id: '1',
      timestamp: '2024-01-15T14:30:00',
      user: 'John Admin',
      action: 'User Permission Update',
      details: 'Modified access rights for Marketing team',
      ipAddress: '192.168.1.100',
      status: 'success',
      category: 'security'
    },
    {
      id: '2',
      timestamp: '2024-01-15T14:25:00',
      user: 'System',
      action: 'Backup Created',
      details: 'Automated system backup completed',
      ipAddress: 'localhost',
      status: 'success',
      category: 'system'
    },
    {
      id: '3',
      timestamp: '2024-01-15T14:20:00',
      user: 'Marie Admin',
      action: 'Failed Login Attempt',
      details: 'Multiple failed login attempts detected',
      ipAddress: '192.168.1.150',
      status: 'error',
      category: 'security'
    },
    {
      id: '4',
      timestamp: '2024-01-15T14:15:00',
      user: 'Pierre Manager',
      action: 'Data Export',
      details: 'Exported customer data report',
      ipAddress: '192.168.1.200',
      status: 'success',
      category: 'data'
    },
    {
      id: '5',
      timestamp: '2024-01-15T14:10:00',
      user: 'System',
      action: 'Performance Alert',
      details: 'High CPU usage detected',
      ipAddress: 'localhost',
      status: 'warning',
      category: 'system'
    }
  ];

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'success':
        return 'check_circle';
      case 'warning':
        return 'warning';
      case 'error':
        return 'error';
      default:
        return 'info';
    }
  };

  const getCategoryIcon = (category: string) => {
    switch (category) {
      case 'security':
        return 'security';
      case 'system':
        return 'computer';
      case 'user':
        return 'person';
      case 'data':
        return 'database';
      default:
        return 'category';
    }
  };

  const filteredLogs = mockAuditLogs.filter(log => {
    const matchesCategory = selectedCategory === 'all' || log.category === selectedCategory;
    const matchesStatus = selectedStatus === 'all' || log.status === selectedStatus;
    const matchesSearch = 
      searchQuery === '' ||
      log.user.toLowerCase().includes(searchQuery.toLowerCase()) ||
      log.action.toLowerCase().includes(searchQuery.toLowerCase()) ||
      log.details.toLowerCase().includes(searchQuery.toLowerCase());
    
    return matchesCategory && matchesStatus && matchesSearch;
  });

  return (
    <div className={styles.auditLogs}>
      <div className={styles.header}>
        <div className={styles.titleSection}>
          <h1 className={styles.title}>Audit Logs</h1>
          <p className={styles.subtitle}>Track and monitor all system activities</p>
        </div>
        <div className={styles.actions}>
          <button className={styles.exportButton}>
            <span className="material-icons">download</span>
            Export Logs
          </button>
        </div>
      </div>

      <div className={styles.filters}>
        <div className={styles.searchBar}>
          <span className="material-icons">search</span>
          <input
            type="text"
            placeholder="Search logs..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
        <div className={styles.filterControls}>
          <select
            value={selectedCategory}
            onChange={(e) => setSelectedCategory(e.target.value)}
            className={styles.filterSelect}
          >
            <option value="all">All Categories</option>
            <option value="security">Security</option>
            <option value="system">System</option>
            <option value="user">User</option>
            <option value="data">Data</option>
          </select>
          <select
            value={selectedStatus}
            onChange={(e) => setSelectedStatus(e.target.value)}
            className={styles.filterSelect}
          >
            <option value="all">All Status</option>
            <option value="success">Success</option>
            <option value="warning">Warning</option>
            <option value="error">Error</option>
          </select>
        </div>
      </div>

      <div className={styles.logList}>
        {filteredLogs.map((log) => (
          <div key={log.id} className={`${styles.logItem} ${styles[log.status]}`}>
            <div className={styles.logIcon}>
              <span className="material-icons">{getCategoryIcon(log.category)}</span>
            </div>
            <div className={styles.logMain}>
              <div className={styles.logHeader}>
                <div className={styles.logAction}>{log.action}</div>
                <div className={styles.logMeta}>
                  <span className={styles.logUser}>
                    <span className="material-icons">person</span>
                    {log.user}
                  </span>
                  <span className={styles.logIp}>
                    <span className="material-icons">router</span>
                    {log.ipAddress}
                  </span>
                  <span className={styles.logTime}>
                    <span className="material-icons">schedule</span>
                    {new Date(log.timestamp).toLocaleString()}
                  </span>
                </div>
              </div>
              <div className={styles.logDetails}>{log.details}</div>
            </div>
            <div className={styles.logStatus}>
              <span className="material-icons">{getStatusIcon(log.status)}</span>
            </div>
          </div>
        ))}
      </div>

      <div className={styles.pagination}>
        <button className={styles.pageButton} disabled>
          <span className="material-icons">chevron_left</span>
        </button>
        <button className={`${styles.pageButton} ${styles.active}`}>1</button>
        <button className={styles.pageButton}>2</button>
        <button className={styles.pageButton}>3</button>
        <span className={styles.pageEllipsis}>...</span>
        <button className={styles.pageButton}>10</button>
        <button className={styles.pageButton}>
          <span className="material-icons">chevron_right</span>
        </button>
      </div>
    </div>
  );
};
