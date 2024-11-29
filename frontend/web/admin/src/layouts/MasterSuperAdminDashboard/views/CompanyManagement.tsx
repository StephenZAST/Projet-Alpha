import React from 'react';
import { useSelector } from 'react-redux';
import { RootState } from '../../../redux/store';
import { AdminUser } from '../../../types/admin';
import styles from './styles/Settings.module.css';

export const Settings: React.FC = () => {
  const user: AdminUser | null = useSelector((state: RootState) => state.auth.user);

  return (
    <div className={styles.settingsContainer}>
      <section className={styles.profileSection}>
        <div className={styles.profileCard}>
          <h3>Informations Personnelles</h3>
          <div className={styles.profileForm}>
            <div className={styles.formGroup}>
              <label>Email</label>
              <input type="email" defaultValue={user?.email || ''} />
            </div>
            <div className={styles.formGroup}>
              <label>Téléphone</label>
              <input type="tel" defaultValue={user?.phone || ''} />
            </div>
            <div className={styles.formGroup}>
              <label>Nom</label>
              <input type="text" defaultValue={user?.name || ''} disabled />
            </div>
            <div className={styles.formGroup}>
              <label>Type Admin</label>
              <input type="text" defaultValue="Master Super Admin" disabled />
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
              <input type="checkbox" defaultChecked />
            </div>
            <div className={styles.preferenceItem}>
              <label>Notifications SMS</label>
              <input type="checkbox" />
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};
