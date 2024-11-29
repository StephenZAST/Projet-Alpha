import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import styles from './style/MasterAdminCreation.module.css';
import AuthService from '../services/AuthService';
import { AppError } from '../utils/errors';

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

  const handleGoogleSignIn = async () => {
    try {
      const result = await AuthService.signInWithGoogle();
      
      // After Google sign-in, create master admin with Google data
      const response = await fetch('/api/admin/master/create', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          ...formData,
          googleId: result.user.uid,
          email: result.user.email,
          firstName: result.user.displayName?.split(' ')[0] || '',
          lastName: result.user.displayName?.split(' ')[1] || '',
        })
      });

      if (response.ok) {
        navigate('/login');
      } else {
        const data = await response.json();
        setError(data.message);
      }
    } catch (err) {
      console.error('Google sign-in error:', err);
      if (err instanceof AppError) {
        setError(err.message);
      } else {
        setError('Failed to create master admin with Google');
      }
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

          <div className={styles.divider}>ou</div>

          <button 
            type="button" 
            onClick={handleGoogleSignIn}
            className={`${styles.submitButton} ${styles.googleButton}`}
          >
            <svg className={styles.googleIcon} viewBox="0 0 48 48">
              <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
              <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
              <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
              <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
            </svg>
            Créer avec Google
          </button>
        </form>
      </div>
    </div>
  );
};

export default MasterAdminCreation;
