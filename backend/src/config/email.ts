import dotenv from 'dotenv';

dotenv.config();

export const emailConfig = {
  provider: process.env.EMAIL_PROVIDER || 'smtp',
  host: 'smtp.gmail.com',  // Hardcoded for Gmail
  port: 587,  // Hardcoded Gmail SMTP port
  secure: false,  // Must be false for port 587
  user: process.env.EMAIL_USER || 'alphalaundry.service1@gmail.com',
  password: process.env.EMAIL_PASSWORD || 'irrq sram tlcm ygfs',  // Your Gmail App Password
  fromName: process.env.EMAIL_FROM_NAME || 'Alpha Laundry',
  fromAddress: process.env.EMAIL_FROM_ADDRESS || 'alphalaundry.service1@gmail.com',
  auth: {  // Added explicit auth configuration
    type: 'login'
  },
  tls: {  // Added explicit TLS configuration
    ciphers: 'SSLv3',
    rejectUnauthorized: true
  }
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
