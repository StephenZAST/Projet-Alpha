import React, { useState, useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Provider } from 'react-redux';
import store from './redux/store';
import PrivateRoute from './components/PrivateRoute';
import Dashboard from './dashboard/Dashboard';
import ErrorBoundary from './components/ErrorBoundary';
import { AuthProvider } from './auth/AuthContext'; // Import AuthProvider

const Login = () => {
  return (
    <div>
      <h1>Login</h1>
      {/* Add login form here */}
    </div>
  );
};

const App: React.FC = () => {
  const [theme, setTheme] = useState(() => {
    if (typeof window !== 'undefined') {
      const savedTheme = localStorage.getItem('theme');
      return savedTheme || (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
    }
    return 'light';
  });

  useEffect(() => {
    if (typeof window !== 'undefined') {
      localStorage.setItem('theme', theme);
      document.documentElement.setAttribute('data-theme', theme);
    }
  }, [theme]);

  const handleThemeToggle = () => {
    setTheme(prevTheme => prevTheme === 'light' ? 'dark' : 'light');
  };

  return (
    <Provider store={store}>
      <ErrorBoundary>
        <AuthProvider> {/* Wrap authenticated routes with AuthProvider */}
          <BrowserRouter>
            <div className="app-container" data-theme={theme}>
              <Routes>
                {/* Redirect root to dashboard */}
                <Route path="/" element={<Navigate to="/dashboard" replace />} />
                
                {/* Dashboard and its nested routes */}
                <Route 
                  path="/dashboard/*" 
                  element={
                    <ErrorBoundary>
                      <PrivateRoute>
                        <Dashboard onThemeToggle={handleThemeToggle} />
                      </PrivateRoute>
                    </ErrorBoundary>
                  } 
                />

                {/* Login route */}
                <Route path="/login" element={<Login />} />
              </Routes>
            </div>
          </BrowserRouter>
        </AuthProvider>
      </ErrorBoundary>
    </Provider>
  );
};

export default App;
