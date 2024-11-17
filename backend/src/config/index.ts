interface EmailConfig {
    host: string;
    port: number;
    secure: boolean;
    user: string;
    password: string;
    fromName: string;
    fromAddress: string;
}

interface Config {
    port: number;
    allowedOrigins: string | string[];
    email: EmailConfig;
    frontendUrl: string;
}

export const config: Config = {
    port: process.env.PORT ? parseInt(process.env.PORT) : 3000,
    allowedOrigins: process.env.ALLOWED_ORIGINS || '*',
    
    // Email configuration
    email: {
        host: process.env.EMAIL_HOST || 'smtp.gmail.com',
        port: parseInt(process.env.EMAIL_PORT || '587'),
        secure: process.env.EMAIL_SECURE === 'true',
        user: process.env.EMAIL_USER || '',
        password: process.env.EMAIL_PASSWORD || '',
        fromName: process.env.EMAIL_FROM_NAME || 'Alpha Laundry',
        fromAddress: process.env.EMAIL_FROM_ADDRESS || 'noreply@alphalaundry.com'
    },

    // Frontend URL for links in emails
    frontendUrl: process.env.FRONTEND_URL || 'http://localhost:3000'
};
