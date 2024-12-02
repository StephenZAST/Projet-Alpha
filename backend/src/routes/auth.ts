import express, { Request, Response, NextFunction } from 'express';
import { authService } from '../services/auth.service';
import { emailService } from '../services/email.service';
import { generateToken } from '../utils/auth';
import { AppError } from '../utils/errors';

const router = express.Router();

// Login with email/password
router.post('/login', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      throw new AppError(400, 'Email and password are required', 'INVALID_CREDENTIALS');
    }

    try {
      const user = await authService.login(email, password);
      
      // Generate JWT token
      const token = generateToken({
        uid: user.uid,
        email: user.email,
        role: user.role
      });

      res.json({
        success: true,
        data: {
          token,
          admin: {
            uid: user.uid,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            role: user.role
          }
        }
      });
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      throw new AppError(401, 'Invalid email or password', 'INVALID_CREDENTIALS');
    }
  } catch (error) {
    next(error);
  }
});

// Test email endpoint
router.post('/test-email', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { to, subject, text } = req.body;

    if (!to) {
      throw new AppError(400, 'Recipient email is required', 'INVALID_EMAIL');
    }

    await emailService.sendEmail({
      to,
      subject: subject || 'Test Email from Alpha Laundry',
      text: text || 'This is a test email from Alpha Laundry system.'
    });

    res.json({
      success: true,
      message: 'Test email sent successfully'
    });
  } catch (error) {
    next(error);
  }
});

export default router;
