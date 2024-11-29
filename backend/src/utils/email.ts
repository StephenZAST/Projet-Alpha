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
    tls: emailConfig.tls,
    debug: true // Enable debug logs
});

// Verify connection configuration
transporter.verify(function (error, success) {
    if (error) {
        console.log('SMTP connection error:', error);
        // Log more details about the error
        console.log('Error details:', {
            name: error.name,
            message: error.message,
            stack: error.stack
        });
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
        const mailOptions = {
            from: `"${emailConfig.fromName}" <${emailConfig.fromAddress}>`,
            to,
            subject,
            html
        };
        
        console.log('Attempting to send email with options:', {
            ...mailOptions,
            html: '[HTML Content]' // Don't log the full HTML for security
        });

        const info = await transporter.sendMail(mailOptions);
        console.log('Email sent successfully:', info.messageId);
    } catch (error) {
        console.error('Failed to send email:', error);
        throw error;
    }
}
