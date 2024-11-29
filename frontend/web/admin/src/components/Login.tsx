import React, { useState, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { login } from '../redux/slices/authSlice';
import { RootState, AppDispatch } from '../redux/store';
import { useNavigate } from 'react-router-dom';
import { Link } from 'react-router-dom';
import styles from './style/Login.module.css';
import AuthService from '../services/AuthService';
import { AppError } from '../utils/errors';

const Login: React.FC = () => {
  const dispatch: AppDispatch = useDispatch();
  const navigate = useNavigate();
  const { isLoggedIn, status, error } = useSelector((state: RootState) => state.auth);

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errorState, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await dispatch(login({ email, password }));
    } catch (err) {
      console.error('Login error:', err);
    }
  };

  const handleGoogleSignIn = async () => {
    try {
      await AuthService.signInWithGoogle();
      navigate('/dashboard');
    } catch (err) {
      console.error('Google login error:', err);
      if (err instanceof AppError) {
        // Handle specific error cases
        setError(err.message);
      } else {
        setError('Failed to sign in with Google');
      }
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
        {errorState && <div className={styles.errorMessage}>{errorState}</div>}

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

          <button type="submit" className={styles.submitButton} disabled={status === 'loading'}>
            {status === 'loading' ? 'Loading...' : 'Se connecter'}
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
            Se connecter avec Google
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
