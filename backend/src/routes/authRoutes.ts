import express, { Request, Response } from 'express';
import { createUser, registerCustomer } from '../services/users/userCreation';
import { verifyEmail, requestPasswordReset, resetPassword, sendVerificationEmail } from '../services/users/userVerification';
import { AppError, errorCodes } from '../utils/errors';
import { validateRequest } from '../middleware/validation/validateRequest';
import { createUserSchema, resetPasswordSchema } from '../validation/users';
import { UserRole, AccountCreationMethod } from '../models/user';
import { generateToken } from '../utils/tokens';
import { auth } from '../config/firebase';

const router = express.Router();

// Register a new user
router.post('/register', validateRequest(createUserSchema), async (req: Request, res: Response) => {
  try {
    const user = await registerCustomer(req.body, AccountCreationMethod.SELF_REGISTRATION);
    res.status(201).json(user);
  } catch (error) {
    if (error instanceof AppError) {
      res.status(error.statusCode).json({ message: error.message, code: errorCodes.SERVER_ERROR });
    } else {
      res.status(500).json({ message: 'Internal Server Error', code: errorCodes.SERVER_ERROR });
    }
  }
});

// Verify user email
router.post('/verify-email', async (req: Request, res: Response) => {
  try {
    await verifyEmail(req.body.token);
    res.json({ message: 'Email verified successfully' });
  } catch (error) {
    if (error instanceof AppError) {
      res.status(error.statusCode).json({ message: error.message, code: errorCodes.SERVER_ERROR });
    } else {
      res.status(500).json({ message: 'Internal Server Error', code: errorCodes.SERVER_ERROR });
    }
  }
});

// Request password reset
router.post('/request-password-reset', async (req: Request, res: Response) => {
  try {
    await requestPasswordReset(req.body.email);
    res.json({ message: 'Password reset instructions sent to your email' });
  } catch (error) {
    if (error instanceof AppError) {
      res.status(error.statusCode).json({ message: error.message, code: errorCodes.SERVER_ERROR });
    } else {
      res.status(500).json({ message: 'Internal Server Error', code: errorCodes.SERVER_ERROR });
    }
  }
});

// Reset password
router.post('/reset-password', validateRequest(resetPasswordSchema), async (req: Request, res: Response) => {
  try {
    await resetPassword(req.body.token, req.body.newPassword);
    res.json({ message: 'Password reset successful' });
  } catch (error) {
    if (error instanceof AppError) {
      res.status(error.statusCode).json({ message: error.message, code: errorCodes.SERVER_ERROR });
    } else {
      res.status(500).json({ message: 'Internal Server Error', code: errorCodes.SERVER_ERROR });
    }
  }
});

// Send verification email
router.post('/send-verification-email', async (req: Request, res: Response) => {
  try {
    const user = await auth.getUserByEmail(req.body.email);
    if (!user) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }
    if (!user.email) {
      throw new AppError(400, 'User email is undefined', errorCodes.VALIDATION_ERROR);
    }
    const verificationToken = await generateToken();
    await sendVerificationEmail(user.email, verificationToken);
    res.json({ message: 'Verification email sent successfully' });
  } catch (error) {
    if (error instanceof AppError) {
      res.status(error.statusCode).json({ message: error.message, code: errorCodes.SERVER_ERROR });
    } else {
      res.status(500).json({ message: 'Internal Server Error', code: errorCodes.SERVER_ERROR });
    }
  }
});

export default router;
