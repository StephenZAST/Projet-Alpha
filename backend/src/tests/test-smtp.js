const nodemailer = require('nodemailer');

const testEmail = async () => {
    // Create test account
    console.log('Creating test SMTP configuration...');

    // Create reusable transporter object using SMTP transport
    const transporter = nodemailer.createTransport({
        host: 'smtp.gmail.com',
        port: 587,
        secure: false,
        auth: {
            user: 'alphalaundry.service1@gmail.com',
            pass: 'irrq sram tlcm ygfs'  // Your App Password
        },
        debug: true
    });

    try {
        // Verify connection configuration
        console.log('Verifying connection...');
        await transporter.verify();
        console.log('Server is ready to take our messages');

        // Send test email
        console.log('Attempting to send test email...');
        const info = await transporter.sendMail({
            from: '"Alpha Laundry" <alphalaundry.service1@gmail.com>',
            to: "alphalaundry.service1@gmail.com", // Send to self for testing
            subject: "Test Email ✔",
            text: "If you receive this email, SMTP is configured correctly.",
            html: "<b>If you receive this email, SMTP is configured correctly.</b>"
        });

        console.log('Message sent: %s', info.messageId);
    } catch (error) {
        console.error('Error occurred:', error);
    }
};

testEmail().catch(console.error);
