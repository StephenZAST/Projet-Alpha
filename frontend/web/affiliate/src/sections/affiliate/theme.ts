import { createTheme } from '@mui/material';

export const theme = createTheme({
  palette: {
    primary: {
      main: '#0045CE',
      light: '#1E4AE9',
      dark: '#00349B'
    },
    success: {
      main: '#00AC4F',
      light: '#DCF5E8'
    },
    error: {
      main: '#D00049',
      light: '#FFE0E3'
    },
    warning: {
      main: '#D29302',
      light: '#FCE6B3'
    },
    grey: {
      50: '#F9FBFF',
      100: '#F0F5F8',
      200: '#EAECF0',
      // ...reste des couleurs du thème Flutter...
    }
  }
});
