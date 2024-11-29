import express from 'express';
import { auth } from '../services/firebase';
import { AppError } from '../utils/errors';
import { generateToken, comparePassword } from '../utils/auth';

const router = express.Router();

// Login with email/password
router.post('/login', async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      throw new AppError(400, 'Email and password are required', 'INVALID_CREDENTIALS');
    }

    // Get user from Firebase
    const userRecord = await auth.getUserByEmail(email);

    // Verify password
    const isPasswordValid = await comparePassword(password, userRecord.passwordHash || '');
    if (!isPasswordValid) {
      throw new AppError(401, 'Invalid email or password', 'INVALID_CREDENTIALS');
    }

    // Generate JWT token using our utility
    const token = generateToken({
      uid: userRecord.uid,
      email: userRecord.email,
      role: userRecord.customClaims?.role || 'user',
    });

    res.json({
      success: true,
      data: {
        token,
        user: {
          uid: userRecord.uid,
          email: userRecord.email,
          role: userRecord.customClaims?.role || 'user',
        },
      },
    });
  } catch (error) {
    next(error);
  }
});

// Google Authentication
router.post('/google', async (req, res, next) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      throw new AppError(400, 'ID token is required', 'INVALID_TOKEN');
    }

    // Verify the ID token
    const decodedToken = await auth.verifyIdToken(idToken);
    
    // Get the user's Firebase record
    const userRecord = await auth.getUser(decodedToken.uid);

    // Generate JWT token using our utility
    const token = generateToken({
      uid: userRecord.uid,
      email: userRecord.email,
      role: userRecord.customClaims?.role || 'user',
    });

    res.json({
      success: true,
      data: {
        token,
        user: {
          uid: userRecord.uid,
          email: userRecord.email,
          role: userRecord.customClaims?.role || 'user',
          displayName: userRecord.displayName,
        },
      },
    });
  } catch (error) {
    next(error);
  }
});

export default router;
