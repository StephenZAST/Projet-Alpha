
:root {
  --theme: light; /* Default theme is light */
  --primary: #0045CE;
  --primary-light: #1E4AE9; /* for button */
  --primary-dark: #00349B;

  --success: #00AC4F;
  --success-light: #DCF5E8;

  --error: #D00049;
  --error-light: #FFE0E3;

  --warning: #D29302;
  --warning-light: #FCE6B3;
  

  --absolute-white: #FFFFFF;


  --primary-gradient: linear-gradient(135deg, #49A3F1 0%, #0045CE 100%);

  --white: #FFFFFF;
  --gray-50: #F9FBFF;
  --gray-100: #F0F5F8;
  --gray-200: #EAECF0;
  --gray-300: #D0D5DD;
  --gray-400: #B5B7C0;
  --gray-500: #737791;
  --gray-600: #5F6980;
  --gray-700: #404B52;
  --gray-800: #282828;
  --gray-900: #000000;
  --theme-shadow: rgba(149, 157, 165, 0.2);

  --primary-box-shadow: rgba(149, 157, 165, 0.2) 0px 8px 24px;
}

[data-theme='dark'] {
  --theme-background-color: #1a1a1a;
  --theme-text-color: #ffffff;
  --theme-card-bg: #242424;
  --theme-border-color: #2d2d2d;
  --theme-sidebar-bg: #242424;
  --theme-hover: #2d2d2d;
  --white: #1F283E;
  --gray-900: #F9FBFF;    
  --gray-800: #F0F5F8;    
  --gray-700: #EAECF0;    
  --gray-600: #D0D5DD;    
  --gray-500: #B5B7C0;    
  --gray-400: #737791;    
  --gray-300: #5F6980;    
  --gray-200: #404B52;    
  --gray-100: #282828;    
  --gray-50: #1A2035;     
  --theme-shadow: rgba(0, 0, 0, 0.3);
  --primary-box-shadow: rgba(149, 157, 165, 0) 0px 8px 24px;
}


:root,
[data-theme='light'],
[data-theme='dark'] {
  transition-property: background-color, color, border-color, box-shadow;
  transition-duration: 200ms;
  transition-timing-function: ease-in-out;
}

body {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto,
    Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', 'Source Sans Pro', sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: var(--theme-text-color);
  line-height: 1.5;
  background-color: var(--theme-background-color);
  transition: background-color 0.3s ease, color 0.3s ease;
}