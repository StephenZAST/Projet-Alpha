import nodemailer from 'nodemailer';
import { AppError } from '../utils/errors';

interface EmailOptions {
  to: string;
  subject?: string;
  text?: string;
  html?: string;
}

class EmailService {
  private transporter: nodemailer.Transporter;

  constructor() {
    // Créer un transporteur SMTP
    this.transporter = nodemailer.createTransport({
      host: process.env.EMAIL_HOST || 'smtp.gmail.com',
      port: parseInt(process.env.EMAIL_PORT || '587'),
      secure: process.env.EMAIL_SECURE === 'true',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASSWORD,
      },
    });
  }

  async sendEmail(options: EmailOptions): Promise<void> {
    try {
      const mailOptions = {
        from: `${process.env.EMAIL_FROM_NAME} <${process.env.EMAIL_FROM_ADDRESS}>`,
        to: options.to,
        subject: options.subject || 'Message from Alpha Laundry',
        text: options.text,
        html: options.html,
      };

      await this.transporter.sendMail(mailOptions);
    } catch (error) {
      console.error('Email sending error:', error);
      throw new AppError(500, 'Failed to send email', 'EMAIL_SEND_FAILED');
    }
  }

  // Méthode pour tester la connexion SMTP
  async testConnection(): Promise<boolean> {
    try {
      await this.transporter.verify();
      return true;
    } catch (error) {
      console.error('SMTP connection test failed:', error);
      return false;
    }
  }
}

export const emailService = new EmailService();
