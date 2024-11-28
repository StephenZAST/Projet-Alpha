import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Provider } from 'react-redux';
import store from './redux/store';
import Login from './components/Login';
import PrivateRoute from './components/PrivateRoute';
import { MasterSuperAdminDashboard } from './layouts/MasterSuperAdminDashboard/MasterSuperAdminDashboard';

const App: React.FC = () => {
  return (
    <Provider store={store}>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route element={<PrivateRoute />}>
            <Route 
              path="/" 
              element={<MasterSuperAdminDashboard />} 
            />
            <Route 
              path="/dashboard" 
              element={<MasterSuperAdminDashboard />} 
            />
            <Route 
              path="/master-admin/*" 
              element={<MasterSuperAdminDashboard />} 
            />
          </Route>
        </Routes>
      </BrowserRouter>
    </Provider>
  );
};

export default App;
