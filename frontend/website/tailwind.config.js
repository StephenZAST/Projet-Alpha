/**
 * 🎨 Tailwind CSS Configuration
 * Configuration optionnelle pour utiliser Tailwind avec CSS Modules
 */

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
          800: '#075985',
          900: '#0c3d66',
          950: '#082f49',
          DEFAULT: '#2563EB',
          light: '#60A5FA',
          dark: '#1E40AF',
        },
        accent: {
          DEFAULT: '#06B6D4',
          light: '#7DD3FC',
          dark: '#0369A1',
        },
        secondary: {
          DEFAULT: '#8B5CF6',
          light: '#EDE9FE',
          dark: '#6D28D9',
        },
      },
      spacing: {
        xs: '4px',
        sm: '8px',
        md: '16px',
        lg: '24px',
        xl: '32px',
        xxl: '48px',
        xxxl: '64px',
      },
      borderRadius: {
        xs: '4px',
        sm: '8px',
        md: '12px',
        lg: '16px',
        xl: '20px',
        xxl: '24px',
      },
      animation: {
        'slide-up': 'slideUp 0.8s cubic-bezier(0.165, 0.84, 0.44, 1) forwards',
        'slide-down': 'slideDown 0.3s cubic-bezier(0, 0, 0.2, 1) forwards',
        'fade-in': 'fadeIn 0.8s cubic-bezier(0, 0, 0.2, 1) forwards',
        'scale-in': 'scaleIn 0.6s cubic-bezier(0.4, 0, 0.2, 1) forwards',
        'float': 'float 3s ease-in-out infinite',
        'pulse': 'pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'glow': 'glow 2s ease-in-out infinite',
      },
      keyframes: {
        slideUp: {
          from: {
            opacity: '0',
            transform: 'translateY(20px)',
          },
          to: {
            opacity: '1',
            transform: 'translateY(0)',
          },
        },
        slideDown: {
          from: {
            opacity: '0',
            transform: 'translateY(-10px)',
          },
          to: {
            opacity: '1',
            transform: 'translateY(0)',
          },
        },
        fadeIn: {
          from: {
            opacity: '0',
          },
          to: {
            opacity: '1',
          },
        },
        scaleIn: {
          from: {
            opacity: '0',
            transform: 'scale(0.95)',
          },
          to: {
            opacity: '1',
            transform: 'scale(1)',
          },
        },
        float: {
          '0%, 100%': {
            transform: 'translateY(0px)',
          },
          '50%': {
            transform: 'translateY(-10px)',
          },
        },
        glow: {
          '0%, 100%': {
            boxShadow: '0 0 20px rgba(37, 99, 235, 0.3)',
          },
          '50%': {
            boxShadow: '0 0 30px rgba(37, 99, 235, 0.5)',
          },
        },
      },
      boxShadow: {
        glass: '0 8px 20px rgba(37, 99, 235, 0.1), 0 2px 6px rgba(0, 0, 0, 0.06)',
        'glass-heavy': '0 8px 20px rgba(37, 99, 235, 0.15), 0 2px 6px rgba(0, 0, 0, 0.3)',
      },
      backdropBlur: {
        glass: '10px',
      },
      fontFamily: {
        sans: ['Inter', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'sans-serif'],
      },
      fontSize: {
        display: ['48px', { lineHeight: '1.1', letterSpacing: '-0.02em' }],
        h1: ['32px', { lineHeight: '1.2', letterSpacing: '-0.02em' }],
        h2: ['24px', { lineHeight: '1.3' }],
        h3: ['20px', { lineHeight: '1.4' }],
        h4: ['18px', { lineHeight: '1.4' }],
        'body-lg': ['18px', { lineHeight: '1.5' }],
        'body-md': ['16px', { lineHeight: '1.5' }],
        'body-sm': ['14px', { lineHeight: '1.4' }],
      },
    },
  },
  plugins: [],
  corePlugins: {
    preflight: false, // Désactiver si vous utilisez CSS Modules
  },
};
