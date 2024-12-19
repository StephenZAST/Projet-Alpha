import dotenv from 'dotenv';
import { logger } from './utils/logger';

dotenv.config();

const config = {
  port: process.env.PORT || 3001,
  allowedOrigins: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : ['http://localhost:3000'],
  email: { // Add email configuration
    host: process.env.EMAIL_HOST,
    port: parseInt(process.env.EMAIL_PORT || '587', 10),
    secure: process.env.EMAIL_SECURE === 'true',
    user: process.env.EMAIL_USER,
    password: process.env.EMAIL_PASSWORD,
    fromName: process.env.EMAIL_FROM_NAME || 'Alpha Laundry',
    fromAddress: process.env.EMAIL_FROM_ADDRESS || 'noreply@alphalaundry.com'
  },
  supabase: {
    url: process.env.SUPABASE_URL as string,
    key: process.env.SUPABASE_KEY as string
  }
};

export default config;
