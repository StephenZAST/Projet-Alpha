import { Resend } from 'resend';
import { emailConfig, appConfig, emailTemplates } from '../config/email';

// Initialize Resend with API key
const resend = new Resend(process.env.RESEND_API_KEY!);

export async function sendVerificationEmail(to: string, token: string): Promise<void> {
  const verificationUrl = `${appConfig.frontendUrl}/verify-email?token=${token}`;

  try {
    await resend.emails.send({
      from: emailConfig.defaultFrom.address,
      to: [to],
      subject: emailTemplates.verification.subject,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
          <h2 style="color: #2C3E50; text-align: center;">Bienvenue chez Alpha Laundry!</h2>
          <div style="background-color: #f8f9fa; border-radius: 10px; padding: 20px; margin: 20px 0;">
            <p style="color: #2C3E50;">Merci de vous être inscrit. Pour activer votre compte, veuillez cliquer sur le bouton ci-dessous :</p>
            <div style="text-align: center; margin: 30px 0;">
              <a href="${verificationUrl}" 
                 style="display: inline-block; padding: 12px 24px; 
                        background-color: #4CAF50; color: white; 
                        text-decoration: none; border-radius: 5px;
                        font-weight: bold;">
                Vérifier mon compte
              </a>
            </div>
            <p style="color: #7f8c8d; font-size: 14px;">Ce lien expirera dans ${emailTemplates.verification.linkValidityHours} heures.</p>
            <p style="color: #7f8c8d; font-size: 14px;">Si vous n'avez pas créé de compte, vous pouvez ignorer cet email.</p>
          </div>
          <div style="text-align: center; margin-top: 30px;">
            <img src="https://your-logo-url.com/logo.png" alt="Alpha Laundry Logo" style="max-width: 150px;">
          </div>
          <hr style="border: 1px solid #eee; margin: 20px 0;">
          <p style="color: #95a5a6; font-size: 12px; text-align: center;">
            Ceci est un email automatique, merci de ne pas y répondre.
          </p>
        </div>
      `,
    });
  } catch (error) {
    console.error('Error sending verification email:', error);
    throw new Error('Failed to send verification email');
  }
}

export async function sendPasswordResetEmail(to: string, token: string): Promise<void> {
  const resetUrl = `${appConfig.frontendUrl}/reset-password?token=${token}`;

  try {
    await resend.emails.send({
      from: emailConfig.defaultFrom.address,
      to: [to],
      subject: emailTemplates.passwordReset.subject,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
          <h2 style="color: #2C3E50; text-align: center;">Réinitialisation de mot de passe</h2>
          <div style="background-color: #f8f9fa; border-radius: 10px; padding: 20px; margin: 20px 0;">
            <p style="color: #2C3E50;">Vous avez demandé la réinitialisation de votre mot de passe. Cliquez sur le bouton ci-dessous pour créer un nouveau mot de passe :</p>
            <div style="text-align: center; margin: 30px 0;">
              <a href="${resetUrl}" 
                 style="display: inline-block; padding: 12px 24px; 
                        background-color: #4CAF50; color: white; 
                        text-decoration: none; border-radius: 5px;
                        font-weight: bold;">
                Réinitialiser mon mot de passe
              </a>
            </div>
            <p style="color: #7f8c8d; font-size: 14px;">Ce lien expirera dans ${emailTemplates.passwordReset.linkValidityHours} heure.</p>
            <p style="color: #7f8c8d; font-size: 14px;">Si vous n'avez pas demandé de réinitialisation de mot de passe, vous pouvez ignorer cet email.</p>
          </div>
          <hr style="border: 1px solid #eee; margin: 20px 0;">
          <p style="color: #95a5a6; font-size: 12px; text-align: center;">
            Ceci est un email automatique, merci de ne pas y répondre.
          </p>
        </div>
      `,
    });
  } catch (error) {
    console.error('Error sending password reset email:', error);
    throw new Error('Failed to send password reset email');
  }
}

export async function sendWelcomeEmail(to: string, name: string): Promise<void> {
  try {
    await resend.emails.send({
      from: emailConfig.defaultFrom.address,
      to: [to],
      subject: emailTemplates.welcome.subject,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
          <h2 style="color: #2C3E50; text-align: center;">Bienvenue ${name}!</h2>
          <div style="background-color: #f8f9fa; border-radius: 10px; padding: 20px; margin: 20px 0;">
            <p style="color: #2C3E50;">Nous sommes ravis de vous compter parmi nos clients.</p>
            <p style="color: #2C3E50;">Avec Alpha Laundry, vous bénéficiez de :</p>
            <ul style="color: #2C3E50; line-height: 1.6;">
              <li>Services de blanchisserie professionnels</li>
              <li>Système de points de fidélité</li>
              <li>Service de livraison à domicile</li>
              <li>Suivi en temps réel de vos commandes</li>
            </ul>
            <p style="color: #2C3E50;">N'hésitez pas à nous contacter si vous avez des questions.</p>
          </div>
          <div style="text-align: center; margin-top: 30px;">
            <img src="https://your-logo-url.com/logo.png" alt="Alpha Laundry Logo" style="max-width: 150px;">
          </div>
          <hr style="border: 1px solid #eee; margin: 20px 0;">
          <p style="color: #95a5a6; font-size: 12px; text-align: center;">
            Ceci est un email automatique, merci de ne pas y répondre.
          </p>
        </div>
      `,
    });
  } catch (error) {
    console.error('Error sending welcome email:', error);
    throw new Error('Failed to send welcome email');
  }
}
