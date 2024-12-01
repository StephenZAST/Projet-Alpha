import React from 'react';
import styles from '../styles/Settings.module.css';

export const Settings: React.FC = () => {
  const mockUser = {
    email: 'admin@example.com',
    phone: '+33 123 456 789',
    name: 'Jean Dupont',
    role: 'Master Super Admin',
    lastLogin: '2023-11-28 14:30',
    accountCreated: '2023-01-15'
  };

  const mockPreferences = {
    notifications: {
      email: true,
      sms: false,
      browser: true,
      mobile: true
    },
    language: 'Français',
    timezone: 'UTC+1',
    theme: 'Light'
  };

  const mockSecuritySettings = {
    twoFactorAuth: true,
    lastPasswordChange: '2023-11-15',
    sessionTimeout: '30 minutes',
    ipWhitelist: ['192.168.1.*', '10.0.0.*']
  };

  return (
    <div className={styles.settingsContainer}>
      <section className={styles.profileSection}>
        <div className={styles.profileCard}>
          <h3>Informations Personnelles</h3>
          <div className={styles.profileForm}>
            <div className={styles.formGroup}>
              <label>Email</label>
              <input type="email" defaultValue={mockUser.email} />
            </div>
            <div className={styles.formGroup}>
              <label>Téléphone</label>
              <input type="tel" defaultValue={mockUser.phone} />
            </div>
            <div className={styles.formGroup}>
              <label>Nom</label>
              <input type="text" defaultValue={mockUser.name} disabled />
            </div>
            <div className={styles.formGroup}>
              <label>Type Admin</label>
              <input type="text" defaultValue={mockUser.role} disabled />
            </div>
            <div className={styles.formGroup}>
              <label>Dernière Connexion</label>
              <input type="text" defaultValue={mockUser.lastLogin} disabled />
            </div>
            <div className={styles.formGroup}>
              <label>Compte Créé le</label>
              <input type="text" defaultValue={mockUser.accountCreated} disabled />
            </div>
            <button className={styles.updateButton}>
              Mettre à jour
            </button>
          </div>
        </div>
      </section>

      <section className={styles.preferencesSection}>
        <div className={styles.preferencesCard}>
          <h3>Préférences</h3>
          <div className={styles.preferencesList}>
            <div className={styles.preferenceItem}>
              <label>Notifications Email</label>
              <input type="checkbox" defaultChecked={mockPreferences.notifications.email} />
            </div>
            <div className={styles.preferenceItem}>
              <label>Notifications SMS</label>
              <input type="checkbox" defaultChecked={mockPreferences.notifications.sms} />
            </div>
            <div className={styles.preferenceItem}>
              <label>Notifications Navigateur</label>
              <input type="checkbox" defaultChecked={mockPreferences.notifications.browser} />
            </div>
            <div className={styles.preferenceItem}>
              <label>Notifications Mobile</label>
              <input type="checkbox" defaultChecked={mockPreferences.notifications.mobile} />
            </div>
            <div className={styles.formGroup}>
              <label>Langue</label>
              <select defaultValue={mockPreferences.language}>
                <option value="Français">Français</option>
                <option value="English">English</option>
              </select>
            </div>
            <div className={styles.formGroup}>
              <label>Fuseau Horaire</label>
              <select defaultValue={mockPreferences.timezone}>
                <option value="UTC+1">UTC+1 (Paris)</option>
                <option value="UTC+0">UTC+0 (London)</option>
              </select>
            </div>
            <div className={styles.formGroup}>
              <label>Thème</label>
              <select defaultValue={mockPreferences.theme}>
                <option value="Light">Clair</option>
                <option value="Dark">Sombre</option>
              </select>
            </div>
          </div>
        </div>
      </section>

      <section className={styles.securitySection}>
        <div className={styles.securityCard}>
          <h3>Sécurité</h3>
          <div className={styles.securitySettings}>
            <div className={styles.preferenceItem}>
              <label>Authentification à Deux Facteurs</label>
              <input type="checkbox" defaultChecked={mockSecuritySettings.twoFactorAuth} />
            </div>
            <div className={styles.formGroup}>
              <label>Dernier Changement de Mot de Passe</label>
              <input type="text" defaultValue={mockSecuritySettings.lastPasswordChange} disabled />
            </div>
            <div className={styles.formGroup}>
              <label>Expiration de Session</label>
              <select defaultValue={mockSecuritySettings.sessionTimeout}>
                <option value="15 minutes">15 minutes</option>
                <option value="30 minutes">30 minutes</option>
                <option value="1 hour">1 heure</option>
              </select>
            </div>
            <div className={styles.ipWhitelist}>
              <label>Liste Blanche IP</label>
              <div className={styles.ipList}>
                {mockSecuritySettings.ipWhitelist.map((ip, index) => (
                  <div key={index} className={styles.ipItem}>
                    <input type="text" defaultValue={ip} />
                    <button className={styles.removeButton}>Supprimer</button>
                  </div>
                ))}
                <button className={styles.addButton}>Ajouter une IP</button>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};
