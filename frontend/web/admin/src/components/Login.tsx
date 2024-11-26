import React, { useState, useEffect } from 'react'; // Import useEffect
import { useDispatch, useSelector } from 'react-redux';
import { login } from '../redux/slices/authSlice';
import { RootState, AppDispatch } from '../redux/store'; // Import AppDispatch
import { useNavigate } from 'react-router-dom';

const Login: React.FC = () => {
  const dispatch: AppDispatch = useDispatch(); // Use AppDispatch type
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
      navigate('/dashboard'); // Redirect to dashboard after successful login
    }
  }, [isLoggedIn, navigate]);

  return (
    <div>
      <h2>Login</h2>
      {status === 'loading' && <div>Loading...</div>}
      {error && <div>{error}</div>}
      <form onSubmit={handleSubmit}>
        <div>
          <label htmlFor="email">Email:</label>
          <input
            type="email"
            id="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </div>
        <div>
          <label htmlFor="password">Password:</label>
          <input
            type="password"
            id="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </div>
        <button type="submit">Login</button>
      </form>
    </div>
  );
};

export default Login;
