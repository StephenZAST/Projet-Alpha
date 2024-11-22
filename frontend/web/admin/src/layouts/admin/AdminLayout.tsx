import { FC } from 'react';
import { Box, CssBaseline, ThemeProvider } from '@mui/material';
import { Outlet } from 'react-router-dom';
import { theme } from '../../theme';
import Sidebar from './components/Sidebar';
import Header from './components/Header';

const AdminLayout: FC = () => {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Box sx={{ display: 'flex' }}>
        <Sidebar />
        <Box sx={{ flexGrow: 1 }}>
          <Header />
          <Box component="main" sx={{ p: 3 }}>
            <Outlet />
          </Box>
        </Box>
      </Box>
    </ThemeProvider>
  );
};

export default AdminLayout;
