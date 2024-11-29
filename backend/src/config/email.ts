import dotenv from 'dotenv';
dotenv.config();

export const emailConfig = {
  provider: 'smtp',
  host: 'smtp.gmail.com',
  port: 587,
  secure: false,
  user: 'alphalaundry.service1@gmail.com',
  password: 'irrq sram tlcm ygfs',
  fromName: 'Alpha Laundry',
  fromAddress: 'alphalaundry.service1@gmail.com'
};

export const appConfig = {
  frontendUrl: process.env.APP_URL || 'http://localhost:5173',
  apiUrl: process.env.API_URL || 'http://localhost:5000',
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
  'EMAIL_FROM_NAME',
  'EMAIL_FROM_ADDRESS',
];

requiredEnvVars.forEach(varName => {
  if (!process.env[varName]) {
    console.error(`Missing required environment variable: ${varName}`);
    process.exit(1);
  }
});
