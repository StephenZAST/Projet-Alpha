import React, { useState } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Provider } from 'react-redux';
import store from './redux/store';
import PrivateRoute from './components/PrivateRoute';
import Dashboard from './dashboard/Dashboard';

const App: React.FC = () => {
  const [theme, setTheme] = useState('light');

  const handleThemeToggle = () => {
    setTheme(theme === 'light' ? 'dark' : 'light');
  };

  return (
    <Provider store={store}>
      <BrowserRouter>
        <div data-theme={theme}>
          <Routes>
            <Route element={<PrivateRoute />}>
              <Route 
                path="/" 
                element={<Dashboard handleThemeToggle={handleThemeToggle} />} 
              />
            </Route>
          </Routes>
        </div>
      </BrowserRouter>
    </Provider>
  );
};

export default App;
