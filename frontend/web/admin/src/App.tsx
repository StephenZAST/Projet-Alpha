import { useState, Suspense } from 'react'
import { BrowserRouter } from 'react-router-dom';
import { CssBaseline, ThemeProvider, CircularProgress, Box } from '@mui/material';
import { theme } from './theme';
import { routes } from './routes';
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import './App.css'

const router = createBrowserRouter(routes);

function App() {
  const [count, setCount] = useState(0)

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
