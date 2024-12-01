import React from 'react';
import styles from '../styles/Settings.module.css';

const Settings: React.FC = () => {
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
    theme: 'light',
    timeZone: 'Europe/Paris'
  };

  return (
    <div className={styles.settingsContainer}>
      <h1>Paramètres du système</h1>
      
      <section className={styles.section}>
        <h2>Profil utilisateur</h2>
        <div className={styles.profileInfo}>
          <div className={styles.infoGroup}>
            <label>Email</label>
            <input type="email" value={mockUser.email} readOnly />
          </div>
          <div className={styles.infoGroup}>
            <label>Téléphone</label>
            <input type="tel" value={mockUser.phone} readOnly />
          </div>
          <div className={styles.infoGroup}>
            <label>Nom</label>
            <input type="text" value={mockUser.name} readOnly />
          </div>
          <div className={styles.infoGroup}>
            <label>Rôle</label>
            <input type="text" value={mockUser.role} readOnly />
          </div>
        </div>
      </section>

      <section className={styles.section}>
        <h2>Préférences</h2>
        <div className={styles.preferences}>
          <div className={styles.preferenceGroup}>
            <h3>Notifications</h3>
            <div className={styles.checkboxGroup}>
              <label>
                <input
                  type="checkbox"
                  checked={mockPreferences.notifications.email}
                  readOnly
                />
                Email
              </label>
              <label>
                <input
                  type="checkbox"
                  checked={mockPreferences.notifications.sms}
                  readOnly
                />
                SMS
              </label>
              <label>
                <input
                  type="checkbox"
                  checked={mockPreferences.notifications.browser}
                  readOnly
                />
                Navigateur
              </label>
              <label>
                <input
                  type="checkbox"
                  checked={mockPreferences.notifications.mobile}
                  readOnly
                />
                Mobile
              </label>
            </div>
          </div>

          <div className={styles.preferenceGroup}>
            <h3>Langue</h3>
            <select value={mockPreferences.language} disabled>
              <option value="Français">Français</option>
              <option value="English">English</option>
            </select>
          </div>

          <div className={styles.preferenceGroup}>
            <h3>Thème</h3>
            <select value={mockPreferences.theme} disabled>
              <option value="light">Clair</option>
              <option value="dark">Sombre</option>
            </select>
          </div>

          <div className={styles.preferenceGroup}>
            <h3>Fuseau horaire</h3>
            <select value={mockPreferences.timeZone} disabled>
              <option value="Europe/Paris">Europe/Paris</option>
              <option value="UTC">UTC</option>
            </select>
          </div>
        </div>
      </section>

      <section className={styles.section}>
        <h2>Informations du compte</h2>
        <div className={styles.accountInfo}>
          <p>
            <strong>Dernière connexion:</strong> {mockUser.lastLogin}
          </p>
          <p>
            <strong>Compte créé le:</strong> {mockUser.accountCreated}
          </p>
        </div>
      </section>

      <div className={styles.actions}>
        <button className={styles.button}>Sauvegarder les modifications</button>
      </div>
    </div>
  );
};

export default Settings;