export const config = {
  port: 3001,
  allowedOrigins: process.env.ALLOWED_ORIGINS || ['http://localhost:3000'],
  email: { // Add email configuration
    host: process.env.EMAIL_HOST,
    port: parseInt(process.env.EMAIL_PORT || '587', 10),
    secure: process.env.EMAIL_SECURE === 'true',
    user: process.env.EMAIL_USER,
    password: process.env.EMAIL_PASSWORD,
    fromName: process.env.EMAIL_FROM_NAME || 'Alpha Laundry',
    fromAddress: process.env.EMAIL_FROM_ADDRESS || 'noreply@alphalaundry.com'
  }
};
