import nodemailer from 'nodemailer';
import { emailConfig } from '../config/email';

// Create reusable transporter object using SMTP transport
const transporter = nodemailer.createTransport({
    host: emailConfig.host,
    port: emailConfig.port,
    secure: emailConfig.secure,
    auth: {
        user: emailConfig.user,
        pass: emailConfig.password
    },
    tls: {
        rejectUnauthorized: false // For development only, remove in production
    }
});

// Verify connection configuration
transporter.verify(function (error, success) {
    if (error) {
        console.log('SMTP connection error:', error);
    } else {
        console.log('SMTP server is ready to take our messages');
    }
});

interface EmailOptions {
    to: string;
    subject: string;
    html: string;
}

/**
 * Send an email
 * @param to Recipient email address
 * @param subject Email subject
 * @param html HTML content of the email
 */
export async function sendEmail({ to, subject, html }: EmailOptions): Promise<void> {
    try {
        await transporter.sendMail({
            from: `"${emailConfig.fromName}" <${emailConfig.fromAddress}>`,
            to,
            subject,
            html
        });
        console.log('Email sent successfully to:', to);
    } catch (error) {
        console.error('Failed to send email:', error);
        throw error;
    }
}
