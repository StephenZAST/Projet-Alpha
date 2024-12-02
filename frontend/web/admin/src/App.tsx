import React, { useState, useEffect, createContext, useContext } from 'react';
import { Provider } from 'react-redux';
import store from './redux/store';
import ErrorBoundary from './components/ErrorBoundary';
import { AuthProvider } from './auth/AuthContext';
import './App.css';

// Créer un contexte pour le thème
interface ThemeContextType {
  theme: 'light' | 'dark';
  toggleTheme: () => void;
}

export const ThemeContext = createContext<ThemeContextType>({
  theme: 'light',
  toggleTheme: () => {},
});

// Hook personnalisé pour utiliser le thème
export const useTheme = () => useContext(ThemeContext);

const App: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [theme, setTheme] = useState<'light' | 'dark'>(() => {
    if (typeof window !== 'undefined') {
      const savedTheme = localStorage.getItem('theme');
      return (savedTheme as 'light' | 'dark') || 
             (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
    }
    return 'light';
  });

  useEffect(() => {
    if (typeof window !== 'undefined') {
      localStorage.setItem('theme', theme);
      document.documentElement.setAttribute('data-theme', theme);
    }
  }, [theme]);

  const toggleTheme = () => {
    setTheme(prevTheme => prevTheme === 'light' ? 'dark' : 'light');
  };

  return (
    <Provider store={store}>
      <ErrorBoundary>
        <AuthProvider>
          <ThemeContext.Provider value={{ theme, toggleTheme }}>
            <div className="app-container" data-theme={theme}>
              {children}
            </div>
          </ThemeContext.Provider>
        </AuthProvider>
      </ErrorBoundary>
    </Provider>
  );
};

export default App;
