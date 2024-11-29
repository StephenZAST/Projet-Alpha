import { emailConfig } from '../config/email';
import { sendEmail } from '../utils/email';

export const sendVerificationEmail = async (to: string, verificationCode: string) => {
    const subject = 'Email Verification - Alpha Laundry';
    const html = `
        <h1>Welcome to Alpha Laundry!</h1>
        <p>Please verify your email address by entering the following code:</p>
        <h2>${verificationCode}</h2>
        <p>If you didn't request this verification, please ignore this email.</p>
    `;

    await sendEmail({
        to,
        subject,
        html
    });
};

export const sendPasswordResetEmail = async (to: string, resetToken: string) => {
    const subject = 'Password Reset Request - Alpha Laundry';
    const resetLink = `${process.env.APP_URL}/reset-password?token=${resetToken}`;
    const html = `
        <h1>Password Reset Request</h1>
        <p>You have requested to reset your password. Click the link below to proceed:</p>
        <a href="${resetLink}">Reset Password</a>
        <p>If you didn't request this password reset, please ignore this email.</p>
        <p>This link will expire in 1 hour.</p>
    `;

    await sendEmail({
        to,
        subject,
        html
    });
};

export async function sendWelcomeEmail(to: string, name: string): Promise<void> {
    try {
        await sendEmail({
            to,
            subject: 'Bienvenue chez Alpha Laundry!',
            html: `
                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
                    <h2 style="color: #2C3E50; text-align: center;">Bienvenue ${name}!</h2>
                    <div style="background-color: #f8f9fa; border-radius: 10px; padding: 20px; margin: 20px 0;">
                        <p style="color: #2C3E50;">Nous sommes ravis de vous compter parmi nos clients.</p>
                        <p style="color: #2C3E50;">Votre compte est maintenant actif et vous pouvez commencer à utiliser nos services.</p>
                    </div>
                    <div style="text-align: center; margin-top: 30px;">
                        <p style="color: #7f8c8d;">L'équipe Alpha Laundry</p>
                    </div>
                </div>
            `
        });
    } catch (error) {
        console.error('Error sending welcome email:', error);
        throw new Error('Failed to send welcome email');
    }
}
