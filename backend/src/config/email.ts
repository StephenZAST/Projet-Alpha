import dotenv from 'dotenv';

dotenv.config();

export const emailConfig = {
  provider: process.env.EMAIL_PROVIDER || 'resend',
  defaultFrom: {
    name: process.env.EMAIL_FROM_NAME || 'Alpha Laundry',
    address: process.env.EMAIL_FROM_ADDRESS || 'alpha@resend.dev',
  },
};

export const appConfig = {
  frontendUrl: process.env.APP_URL || 'http://localhost:3000',
  apiUrl: process.env.API_URL || 'http://localhost:3001',
};

// Email templates configuration
export const emailTemplates = {
  verification: {
    subject: 'Vérifiez votre compte Alpha Laundry',
    linkValidityHours: 24,
  },
  passwordReset: {
    subject: 'Réinitialisation de votre mot de passe Alpha Laundry',
    linkValidityHours: 1,
  },
  welcome: {
    subject: 'Bienvenue chez Alpha Laundry!',
  },
};

// Validate required environment variables
const requiredEnvVars = [
  'RESEND_API_KEY',
  'EMAIL_FROM_NAME',
  'EMAIL_FROM_ADDRESS',
];

requiredEnvVars.forEach(varName => {
  if (!process.env[varName]) {
    console.error(`Missing required environment variable: ${varName}`);
    process.exit(1);
  }
});
