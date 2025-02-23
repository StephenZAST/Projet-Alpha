import nodemailer from 'nodemailer';

const transporter = nodemailer.createTransport({
  host: process.env.EMAIL_HOST,
  port: parseInt(process.env.EMAIL_PORT || '587'),
  secure: process.env.EMAIL_SECURE === 'true',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD
  }
});

export const sendEmail = async (to: string, code: string) => {
  console.log('Attempting to send email to:', to);
  
  const mailOptions = {
    from: `"${process.env.EMAIL_FROM_NAME}" <${process.env.EMAIL_FROM_ADDRESS}>`,
    to: to,
    subject: 'Code de réinitialisation de mot de passe',
    html: `
      <h1>Réinitialisation de mot de passe</h1>
      <p>Votre code de vérification est : <strong>${code}</strong></p>
      <p>Ce code expirera dans 15 minutes.</p>
    `
  }; 

  try {
    console.log('Email configuration:', {
      host: process.env.EMAIL_HOST,
      port: process.env.EMAIL_PORT,
      secure: process.env.EMAIL_SECURE === 'true',
      from: process.env.EMAIL_FROM_ADDRESS
    });

    const result = await transporter.sendMail(mailOptions);
    console.log('Email sent successfully:', result);
    return result;
  } catch (error) {
    console.error('Error sending email:', error);
    throw error;
  }
}; 