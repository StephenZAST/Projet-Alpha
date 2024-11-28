import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Login from './components/Login';
import TeamManagement from './components/TeamManagement';
import PrivateRoute from './components/PrivateRoute';
import { DashboardLayout } from './layouts/DashboardLayout/DashboardLayout';

const App: React.FC = () => {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/" element={
          <DashboardLayout
            children={<div>Dashboard content</div>}
            sidebarItems={[
              { icon: '/icons/dashboard.svg', label: 'Dashboard', value: 'dashboard' },
              { icon: '/icons/teams.svg', label: 'Teams', value: 'teams' },
            ]}
            selectedView="dashboard"
            onViewChange={(view) => console.log(view)}
            userRole="Admin"
          />
        } /> {/* Default route moved outside PrivateRoute */}
        <Route element={<PrivateRoute />}>
          <Route path="/dashboard" element={
            <DashboardLayout
              children={<div>Dashboard content</div>}
              sidebarItems={[
                { icon: '/icons/dashboard.svg', label: 'Dashboard', value: 'dashboard' },
                { icon: '/icons/teams.svg', label: 'Teams', value: 'teams' },
              ]}
              selectedView="dashboard"
              onViewChange={(view) => console.log(view)}
              userRole="Admin"
            />
          } />
          <Route path="/teams" element={<TeamManagement />} />
          {/* Add other protected routes here */}
        </Route>
      </Routes>
    </BrowserRouter>
  );
};

export default App;
