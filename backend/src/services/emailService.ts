import * as nodemailer from 'nodemailer';
import config from '../config';

// Create a transporter using environment variables
const transporter = nodemailer.createTransport({
  host: config.email.host,
  port: config.email.port,
  secure: config.email.secure,
  auth: {
    user: config.email.user,
    pass: config.email.password,
  },
});

export async function sendVerificationEmail(to: string, token: string): Promise<void> {
  const verificationUrl = `${config.appUrl}/verify-email?token=${token}`;

  const mailOptions = {
    from: config.email.from,
    to,
    subject: 'Vérifiez votre compte Alpha Laundry',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2>Bienvenue chez Alpha Laundry!</h2>
        <p>Merci de vous être inscrit. Pour activer votre compte, veuillez cliquer sur le lien ci-dessous :</p>
        <p>
          <a href="${verificationUrl}" style="display: inline-block; padding: 10px 20px; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 5px;">
            Vérifier mon compte
          </a>
        </p>
        <p>Ce lien expirera dans 24 heures.</p>
        <p>Si vous n'avez pas créé de compte, vous pouvez ignorer cet email.</p>
        <hr>
        <p style="font-size: 12px; color: #666;">
          Ceci est un email automatique, merci de ne pas y répondre.
        </p>
      </div>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
  } catch (error) {
    console.error('Error sending verification email:', error);
    throw new Error('Failed to send verification email');
  }
}

export async function sendPasswordResetEmail(to: string, token: string): Promise<void> {
  const resetUrl = `${config.appUrl}/reset-password?token=${token}`;

  const mailOptions = {
    from: config.email.from,
    to,
    subject: 'Réinitialisation de votre mot de passe Alpha Laundry',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2>Réinitialisation de mot de passe</h2>
        <p>Vous avez demandé la réinitialisation de votre mot de passe. Cliquez sur le lien ci-dessous pour créer un nouveau mot de passe :</p>
        <p>
          <a href="${resetUrl}" style="display: inline-block; padding: 10px 20px; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 5px;">
            Réinitialiser mon mot de passe
          </a>
        </p>
        <p>Ce lien expirera dans 1 heure.</p>
        <p>Si vous n'avez pas demandé de réinitialisation de mot de passe, vous pouvez ignorer cet email.</p>
        <hr>
        <p style="font-size: 12px; color: #666;">
          Ceci est un email automatique, merci de ne pas y répondre.
        </p>
      </div>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
  } catch (error) {
    console.error('Error sending password reset email:', error);
    throw new Error('Failed to send password reset email');
  }
}

export async function sendWelcomeEmail(to: string, name: string): Promise<void> {
  const mailOptions = {
    from: config.email.from,
    to,
    subject: 'Bienvenue chez Alpha Laundry!',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2>Bienvenue ${name}!</h2>
        <p>Nous sommes ravis de vous compter parmi nos clients.</p>
        <p>Avec Alpha Laundry, vous bénéficiez de :</p>
        <ul>
          <li>Services de blanchisserie professionnels</li>
          <li>Système de points de fidélité</li>
          <li>Service de livraison à domicile</li>
          <li>Suivi en temps réel de vos commandes</li>
        </ul>
        <p>N'hésitez pas à nous contacter si vous avez des questions.</p>
        <hr>
        <p style="font-size: 12px; color: #666;">
          Ceci est un email automatique, merci de ne pas y répondre.
        </p>
      </div>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
  } catch (error) {
    console.error('Error sending welcome email:', error);
    throw new Error('Failed to send welcome email');
  }
}
