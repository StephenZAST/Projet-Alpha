import nodemailer from 'nodemailer';
import { config } from '../config';

// Create reusable transporter object using SMTP transport
const transporter = nodemailer.createTransport({
    host: config.email.host,
    port: config.email.port,
    secure: config.email.secure,
    auth: {
        user: config.email.user,
        pass: config.email.password
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
            from: `"${config.email.fromName}" <${config.email.fromAddress}>`,
            to,
            subject,
            html
        });
    } catch (error) {
        console.error('Failed to send email:', error);
        throw error;
    }
}
