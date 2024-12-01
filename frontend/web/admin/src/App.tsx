import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Provider } from 'react-redux';
import store from './redux/store';
import Login from './components/Login';
import MasterAdminCreation from './components/MasterAdminCreation';
import PrivateRoute from './components/PrivateRoute';
import { MasterSuperAdminDashboard } from './layouts/MasterSuperAdminDashboard/MasterSuperAdminDashboard';

const App: React.FC = () => {
  return (
    <Provider store={store}>
      <BrowserRouter>
        <Routes>
          {/* Public routes */}
          <Route path="/login" element={<Login />} />
          <Route path="/create-master-admin" element={<MasterAdminCreation />} />
          
          {/* Protected routes */}
          <Route element={<PrivateRoute />}>
            <Route path="/" element={<Navigate to="/dashboard" replace />} />
            <Route path="/dashboard/*" element={<MasterSuperAdminDashboard />} />
            <Route path="/master-admin/*" element={<MasterSuperAdminDashboard />} />
          </Route>

          {/* Catch all route - redirect to dashboard if authenticated */}
          <Route path="*" element={<Navigate to="/dashboard" replace />} />
        </Routes>
      </BrowserRouter>
    </Provider>
  );
};

export default App;
