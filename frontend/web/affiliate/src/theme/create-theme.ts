import type { Theme } from '@mui/material/styles';

import { experimental_extendTheme as extendTheme } from '@mui/material/styles';

import { shadows, typography, components, colorSchemes } from './core';

// ----------------------------------------------------------------------

export function createTheme(): Theme {
  const initialTheme = {
    colorSchemes: {
      ...colorSchemes,
      light: {
        ...colorSchemes.light,
        primary: {
          main: '#0045CE',
          light: '#1E4AE9',
          dark: '#00349B'
        },
        success: {
          main: '#00AC4F',
          light: '#DCF5E8'
        }
      }
    },
    shadows: shadows(),
    customShadows: customShadows(),
    shape: { borderRadius: 8 },
    components,
    typography,
    cssVarPrefix: '',
    shouldSkipGeneratingVar,
  };

  const theme = extendTheme(initialTheme);

  return theme;
}

// ----------------------------------------------------------------------

function shouldSkipGeneratingVar(keys: string[], value: string | number): boolean {
  const skipGlobalKeys = [
    'mixins',
    'overlays',
    'direction',
    'typography',
    'breakpoints',
    'transitions',
    'cssVarPrefix',
    'unstable_sxConfig',
  ];

  const skipPaletteKeys: {
    [key: string]: string[];
  } = {
    global: ['tonalOffset', 'dividerChannel', 'contrastThreshold'],
    grey: ['A100', 'A200', 'A400', 'A700'],
    text: ['icon'],
  };

  const isPaletteKey = keys[0] === 'palette';

  if (isPaletteKey) {
    const paletteType = keys[1];
    const skipKeys = skipPaletteKeys[paletteType] || skipPaletteKeys.global;

    return keys.some((key) => skipKeys?.includes(key));
  }

  return keys.some((key) => skipGlobalKeys?.includes(key));
}
