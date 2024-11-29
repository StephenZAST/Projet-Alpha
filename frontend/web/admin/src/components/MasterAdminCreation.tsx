import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import styles from './style/MasterAdminCreation.module.css';

const MasterAdminCreation: React.FC = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    firstName: '',
    lastName: '',
    phoneNumber: ''
  });
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const response = await fetch('/api/admin/master/create', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData)
      });

      if (response.ok) {
        navigate('/login');
      } else {
        const data = await response.json();
        setError(data.message);
      }
    } catch {
      setError('Creation failed. Please try again.');
    }
  };

  return (
    <div className={styles.container}>
      <div className={styles.formCard}>
        <h2 className={styles.title}>Créer le Compte Master Admin</h2>
        {error && <div className={styles.error}>{error}</div>}
        
        <form onSubmit={handleSubmit} className={styles.form}>
          <div className={styles.formGroup}>
            <label>Email</label>
            <input
              type="email"
              value={formData.email}
              onChange={e => setFormData({...formData, email: e.target.value})}
            />
          </div>
          
          <div className={styles.formGroup}>
            <label>Mot de passe</label>
            <input
              type="password"
              value={formData.password}
              onChange={e => setFormData({...formData, password: e.target.value})}
            />
          </div>
          
          <div className={styles.formGroup}>
            <label>Prénom</label>
            <input
              type="text"
              value={formData.firstName}
              onChange={e => setFormData({...formData, firstName: e.target.value})}
            />
          </div>
          
          <div className={styles.formGroup}>
            <label>Nom</label>
            <input
              type="text"
              value={formData.lastName}
              onChange={e => setFormData({...formData, lastName: e.target.value})}
            />
          </div>
          
          <div className={styles.formGroup}>
            <label>Téléphone</label>
            <input
              type="tel"
              value={formData.phoneNumber}
              onChange={e => setFormData({...formData, phoneNumber: e.target.value})}
            />
          </div>

          <button type="submit" className={styles.submitButton}>
            Créer le Compte
          </button>
        </form>
      </div>
    </div>
  );
};

export default MasterAdminCreation;
