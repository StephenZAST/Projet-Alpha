import express, { Request, Response, NextFunction } from 'express';
import { sendEmail } from '../../utils/email';
import { AppError, errorCodes } from '../../utils/errors';

const router = express.Router();

router.post('/', async (req: Request, res: Response, next: NextFunction) => {
    try {
        await sendEmail({
            to: 'alphalaundry.service1@gmail.com', // Send to your email
            subject: 'Test Email from Alpha Laundry',
            html: `
                <h1>Test Email</h1>
                <p>This is a test email from Alpha Laundry system.</p>
                <p>If you received this, the email system is working correctly!</p>
                <p>Time sent: ${new Date().toLocaleString()}</p>
            `
        });
        res.json({ message: 'Test email sent successfully!' });
    } catch (error) {
        console.error('Error sending test email:', error);
        next(new AppError(500, 'Failed to send test email', errorCodes.EMAIL_SEND_ERROR));
    }
});

export default router;
