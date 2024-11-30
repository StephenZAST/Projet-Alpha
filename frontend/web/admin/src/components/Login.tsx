import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import styles from './style/Login.module.css';
import AuthService from '../services/AuthService';
import { AppError } from '../utils/errors';

const Login: React.FC = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    email: '',
    password: ''
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      console.log('Attempting login with:', formData.email);
      const result = await AuthService.login(formData.email, formData.password);
      console.log('Login successful:', result);
      navigate('/dashboard');
    } catch (err) {
      console.error('Login error:', err);
      if (err instanceof AppError) {
        setError(err.message);
      } else {
        setError('Login failed. Please check your credentials and try again.');
      }
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  return (
    <div className={styles.container}>
      <div className={styles.formWrapper}>
        <h2>Login to Admin Dashboard</h2>
        {error && <div className={styles.error}>{error}</div>}
        <form onSubmit={handleSubmit}>
          <div className={styles.formGroup}>
            <label htmlFor="email">Email</label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleInputChange}
              required
              disabled={loading}
            />
          </div>
          <div className={styles.formGroup}>
            <label htmlFor="password">Password</label>
            <input
              type="password"
              id="password"
              name="password"
              value={formData.password}
              onChange={handleInputChange}
              required
              disabled={loading}
            />
          </div>
          <button 
            type="submit" 
            className={styles.submitButton}
            disabled={loading}
          >
            {loading ? 'Logging in...' : 'Login'}
          </button>
        </form>
        <div className={styles.links}>
          <p>
            Don't have an account?{' '}
            <a href="/create-master-admin" className={styles.link}>
              Create Master Admin Account
            </a>
          </p>
        </div>
      </div>
    </div>
  );
};

export default Login;
