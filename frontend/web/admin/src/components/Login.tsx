import React, { useState, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { login } from '../redux/slices/authSlice';
import { RootState, AppDispatch } from '../redux/store';
import { useNavigate } from 'react-router-dom';
import { Link } from 'react-router-dom';
import styles from './style/Login.module.css';

const Login: React.FC = () => {
  const dispatch: AppDispatch = useDispatch();
  const navigate = useNavigate();
  const { isLoggedIn, status, error } = useSelector((state: RootState) => state.auth);

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await dispatch(login({ email, password }));
    } catch (err) {
      console.error('Login error:', err);
    }
  };

  useEffect(() => {
    if (isLoggedIn) {
      navigate('/dashboard');
    }
  }, [isLoggedIn, navigate]);

  return (
    <div className={styles.loginContainer}>
      <div className={styles.loginCard}>
        <h2 className={styles.loginTitle}>Connexion</h2>

        {status === 'loading' && <div className={styles.loadingState}>Chargement...</div>}
        {error && <div className={styles.errorMessage}>{error}</div>}

        <form onSubmit={handleSubmit} className={styles.loginForm}>
          <div className={styles.formGroup}>
            <label htmlFor="email" className={styles.inputLabel}>
              Email:
            </label>
            <input
              type="email"
              id="email"
              className={styles.inputField}
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="Entrez votre email"
            />
          </div>

          <div className={styles.formGroup}>
            <label htmlFor="password" className={styles.inputLabel}>
              Mot de passe:
            </label>
            <input
              type="password"
              id="password"
              className={styles.inputField}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Entrez votre mot de passe"
            />
          </div>

          <button type="submit" className={styles.submitButton}>
            Se connecter
          </button>
        </form>

        <div className={styles.masterAdminLink}>
          <Link to="/create-master-admin">
            Première connexion ? Créer un compte Master Admin
          </Link>
        </div>
      </div>
    </div>
  );
};

export default Login;
