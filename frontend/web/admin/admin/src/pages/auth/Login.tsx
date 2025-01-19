import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import { LoginCredentials } from '../../types/auth';
import { colors } from '../../theme/colors';

export const Login = () => {
  const [credentials, setCredentials] = useState<LoginCredentials>({
    email: '',
    password: ''
  });
  const [error, setError] = useState('');
  const { login, state } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      console.log('Submitting login form with credentials:', credentials); // Ajoutez ce log
      await login(credentials);
      console.log('Login successful, navigating to dashboard');
      navigate('/dashboard');
    } catch (err: Error | unknown) {
      console.error('Login form submission error:', err); // Ajoutez ce log
      const error = err as { response?: { data?: { error?: string } } };
      setError(error.response?.data?.error || 'Login failed');
    }
  };

  return (
    <div style={{
      height: '100vh',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      backgroundColor: colors.gray50
    }}>
      <div style={{
        width: '100%',
        maxWidth: '400px',
        padding: '32px',
        backgroundColor: colors.white,
        borderRadius: '12px',
        boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
      }}>
        <h1 style={{ marginBottom: '24px', textAlign: 'center', color: colors.gray800 }}>
          Admin Login
        </h1>
        <form onSubmit={handleSubmit}>
          <input
            type="email"
            value={credentials.email}
            onChange={(e) => setCredentials(prev => ({
              ...prev,
              email: e.target.value
            }))}
            placeholder="Email"
            required
          />
          <input
            type="password"
            value={credentials.password}
            onChange={(e) => setCredentials(prev => ({
              ...prev,
              password: e.target.value
            }))}
            placeholder="Password"
            required
          />
          {error && (
            <p style={{ color: colors.error, marginBottom: '16px', textAlign: 'center' }}>
              {error}
            </p>
          )}
          <button type="submit" style={{ width: '100%' }} disabled={state.loading}>
            {state.loading ? 'Loading...' : 'Login'}
          </button>
        </form>
      </div>
    </div>
  );
};