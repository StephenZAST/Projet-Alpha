import { Suspense } from 'react'
import { CssBaseline, ThemeProvider, CircularProgress, Box } from '@mui/material';
import { theme } from './theme';
import { routes } from './routes';
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import './App.css'

const router = createBrowserRouter(routes);

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Suspense
        fallback={
          <Box
            sx={{
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center',
              height: '100vh',
            }}
          >
            <CircularProgress />
          </Box>
        }
      >
        <RouterProvider router={router} />
      </Suspense>
    </ThemeProvider>
  );
}

export default App
