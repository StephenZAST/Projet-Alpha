import React, { useState } from 'react';
import styles from './SystemSettings.module.css';

interface SystemConfig {
  maintenance: boolean;
  debugMode: boolean;
  maxLoginAttempts: number;
  sessionTimeout: number;
  emailNotifications: boolean;
  backupFrequency: string;
  logRetentionDays: number;
}

interface SecuritySettings {
  passwordMinLength: number;
  requireSpecialChars: boolean;
  requireNumbers: boolean;
  requireUppercase: boolean;
  mfaEnabled: boolean;
  ipWhitelist: string[];
}

export const SystemSettings: React.FC = () => {
  const [activeTab, setActiveTab] = useState('general');
  const [systemConfig, setSystemConfig] = useState<SystemConfig>({
    maintenance: false,
    debugMode: false,
    maxLoginAttempts: 5,
    sessionTimeout: 30,
    emailNotifications: true,
    backupFrequency: 'daily',
    logRetentionDays: 30,
  });

  const [securitySettings, setSecuritySettings] = useState<SecuritySettings>({
    passwordMinLength: 8,
    requireSpecialChars: true,
    requireNumbers: true,
    requireUppercase: true,
    mfaEnabled: true,
    ipWhitelist: ['192.168.1.1', '10.0.0.1'],
  });

  const handleConfigChange = (key: keyof SystemConfig, value: SystemConfig[keyof SystemConfig]) => {
    setSystemConfig(prev => ({ ...prev, [key]: value }));
  };

  const handleSecurityChange = (key: keyof SecuritySettings, value: SecuritySettings[keyof SecuritySettings]) => {
    setSecuritySettings(prev => ({ ...prev, [key]: value }));
  };

  return (
    <div className={styles.systemSettings}>
      <div className={styles.header}>
        <h1 className={styles.title}>System Settings</h1>
        <button className={styles.saveButton}>
          <span className="material-icons">save</span>
          Save Changes
        </button>
      </div>

      <div className={styles.tabs}>
        <button
          className={`${styles.tabButton} ${activeTab === 'general' ? styles.active : ''}`}
          onClick={() => setActiveTab('general')}
        >
          <span className="material-icons">settings</span>
          General
        </button>
        <button
          className={`${styles.tabButton} ${activeTab === 'security' ? styles.active : ''}`}
          onClick={() => setActiveTab('security')}
        >
          <span className="material-icons">security</span>
          Security
        </button>
        <button
          className={`${styles.tabButton} ${activeTab === 'backup' ? styles.active : ''}`}
          onClick={() => setActiveTab('backup')}
        >
          <span className="material-icons">backup</span>
          Backup & Logs
        </button>
        <button
          className={`${styles.tabButton} ${activeTab === 'notifications' ? styles.active : ''}`}
          onClick={() => setActiveTab('notifications')}
        >
          <span className="material-icons">notifications</span>
          Notifications
        </button>
      </div>

      <div className={styles.content}>
        {activeTab === 'general' && (
          <div className={styles.section}>
            <h2 className={styles.sectionTitle}>General Settings</h2>
            
            <div className={styles.settingGroup}>
              <div className={styles.settingItem}>
                <div className={styles.settingHeader}>
                  <h3>Maintenance Mode</h3>
                  <p className={styles.description}>
                    Enable maintenance mode to prevent user access during system updates
                  </p>
                </div>
                <label className={styles.switch}>
                  <input
                    type="checkbox"
                    checked={systemConfig.maintenance}
                    onChange={(e) => handleConfigChange('maintenance', e.target.checked)}
                  />
                  <span className={styles.slider}></span>
                </label>
              </div>

              <div className={styles.settingItem}>
                <div className={styles.settingHeader}>
                  <h3>Debug Mode</h3>
                  <p className={styles.description}>
                    Enable detailed error messages and logging
                  </p>
                </div>
                <label className={styles.switch}>
                  <input
                    type="checkbox"
                    checked={systemConfig.debugMode}
                    onChange={(e) => handleConfigChange('debugMode', e.target.checked)}
                  />
                  <span className={styles.slider}></span>
                </label>
              </div>

              <div className={styles.settingItem}>
                <div className={styles.settingHeader}>
                  <h3>Session Timeout</h3>
                  <p className={styles.description}>
                    Time in minutes before an inactive session expires
                  </p>
                </div>
                <input
                  type="number"
                  value={systemConfig.sessionTimeout}
                  onChange={(e) => handleConfigChange('sessionTimeout', parseInt(e.target.value))}
                  className={styles.numberInput}
                  min="5"
                  max="120"
                />
              </div>
            </div>
          </div>
        )}

        {activeTab === 'security' && (
          <div className={styles.section}>
            <h2 className={styles.sectionTitle}>Security Settings</h2>
            
            <div className={styles.settingGroup}>
              <div className={styles.settingItem}>
                <div className={styles.settingHeader}>
                  <h3>Password Requirements</h3>
                </div>
                <div className={styles.passwordSettings}>
                  <div className={styles.settingRow}>
                    <label>Minimum Length</label>
                    <input
                      type="number"
                      value={securitySettings.passwordMinLength}
                      onChange={(e) => handleSecurityChange('passwordMinLength', parseInt(e.target.value))}
                      className={styles.numberInput}
                      min="6"
                      max="32"
                    />
                  </div>
                  <div className={styles.settingRow}>
                    <label>Require Special Characters</label>
                    <label className={styles.switch}>
                      <input
                        type="checkbox"
                        checked={securitySettings.requireSpecialChars}
                        onChange={(e) => handleSecurityChange('requireSpecialChars', e.target.checked)}
                      />
                      <span className={styles.slider}></span>
                    </label>
                  </div>
                  <div className={styles.settingRow}>
                    <label>Require Numbers</label>
                    <label className={styles.switch}>
                      <input
                        type="checkbox"
                        checked={securitySettings.requireNumbers}
                        onChange={(e) => handleSecurityChange('requireNumbers', e.target.checked)}
                      />
                      <span className={styles.slider}></span>
                    </label>
                  </div>
                  <div className={styles.settingRow}>
                    <label>Require Uppercase</label>
                    <label className={styles.switch}>
                      <input
                        type="checkbox"
                        checked={securitySettings.requireUppercase}
                        onChange={(e) => handleSecurityChange('requireUppercase', e.target.checked)}
                      />
                      <span className={styles.slider}></span>
                    </label>
                  </div>
                </div>
              </div>

              <div className={styles.settingItem}>
                <div className={styles.settingHeader}>
                  <h3>Two-Factor Authentication</h3>
                  <p className={styles.description}>
                    Require two-factor authentication for all admin accounts
                  </p>
                </div>
                <label className={styles.switch}>
                  <input
                    type="checkbox"
                    checked={securitySettings.mfaEnabled}
                    onChange={(e) => handleSecurityChange('mfaEnabled', e.target.checked)}
                  />
                  <span className={styles.slider}></span>
                </label>
              </div>

              <div className={styles.settingItem}>
                <div className={styles.settingHeader}>
                  <h3>IP Whitelist</h3>
                  <p className={styles.description}>
                    Restrict admin access to specific IP addresses
                  </p>
                </div>
                <div className={styles.ipList}>
                  {securitySettings.ipWhitelist.map((ip, index) => (
                    <div key={index} className={styles.ipItem}>
                      <span>{ip}</span>
                      <button
                        className={styles.removeButton}
                        onClick={() => {
                          const newList = securitySettings.ipWhitelist.filter((_, i) => i !== index);
                          handleSecurityChange('ipWhitelist', newList);
                        }}
                      >
                        <span className="material-icons">close</span>
                      </button>
                    </div>
                  ))}
                  <button className={styles.addButton}>
                    <span className="material-icons">add</span>
                    Add IP Address
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'backup' && (
          <div className={styles.section}>
            <h2 className={styles.sectionTitle}>Backup & Logs</h2>
            
            <div className={styles.settingGroup}>
              <div className={styles.settingItem}>
                <div className={styles.settingHeader}>
                  <h3>Backup Frequency</h3>
                  <p className={styles.description}>
                    How often should the system create backups
                  </p>
                </div>
                <select
                  value={systemConfig.backupFrequency}
                  onChange={(e) => handleConfigChange('backupFrequency', e.target.value)}
                  className={styles.select}
                >
                  <option value="hourly">Every Hour</option>
                  <option value="daily">Daily</option>
                  <option value="weekly">Weekly</option>
                  <option value="monthly">Monthly</option>
                </select>
              </div>

              <div className={styles.settingItem}>
                <div className={styles.settingHeader}>
                  <h3>Log Retention</h3>
                  <p className={styles.description}>
                    Number of days to keep system logs
                  </p>
                </div>
                <input
                  type="number"
                  value={systemConfig.logRetentionDays}
                  onChange={(e) => handleConfigChange('logRetentionDays', parseInt(e.target.value))}
                  className={styles.numberInput}
                  min="1"
                  max="365"
                />
              </div>

              <div className={styles.actionButtons}>
                <button className={styles.actionButton}>
                  <span className="material-icons">backup</span>
                  Create Manual Backup
                </button>
                <button className={styles.actionButton}>
                  <span className="material-icons">download</span>
                  Download Latest Logs
                </button>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'notifications' && (
          <div className={styles.section}>
            <h2 className={styles.sectionTitle}>Notification Settings</h2>
            
            <div className={styles.settingGroup}>
              <div className={styles.settingItem}>
                <div className={styles.settingHeader}>
                  <h3>Email Notifications</h3>
                  <p className={styles.description}>
                    Send system alerts and notifications via email
                  </p>
                </div>
                <label className={styles.switch}>
                  <input
                    type="checkbox"
                    checked={systemConfig.emailNotifications}
                    onChange={(e) => handleConfigChange('emailNotifications', e.target.checked)}
                  />
                  <span className={styles.slider}></span>
                </label>
              </div>

              <div className={styles.notificationTypes}>
                <h3>Notification Types</h3>
                <div className={styles.checkboxGroup}>
                  <label className={styles.checkbox}>
                    <input type="checkbox" defaultChecked />
                    <span>Security Alerts</span>
                  </label>
                  <label className={styles.checkbox}>
                    <input type="checkbox" defaultChecked />
                    <span>System Updates</span>
                  </label>
                  <label className={styles.checkbox}>
                    <input type="checkbox" defaultChecked />
                    <span>User Activities</span>
                  </label>
                  <label className={styles.checkbox}>
                    <input type="checkbox" defaultChecked />
                    <span>Backup Status</span>
                  </label>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
