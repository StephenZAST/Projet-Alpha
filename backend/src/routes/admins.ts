import express from 'express';
import { auth } from '../services/firebase';
import { AppError } from '../utils/errors';
import { generateToken, hashPassword, validatePasswordStrength } from '../utils/auth';

const router = express.Router();

// Create Master Admin
router.post('/master/create', async (req, res, next) => {
  try {
    const { email, password, firstName, lastName, phoneNumber } = req.body;

    // Validate required fields
    if (!email || !password) {
      throw new AppError('Email and password are required', 400, 'INVALID_ADMIN_DATA');
    }

    // Validate password strength
    validatePasswordStrength(password);

    // Hash the password
    const hashedPassword = await hashPassword(password);

    // Create user in Firebase
    const userRecord = await auth.createUser({
      email,
      password: hashedPassword, // Use the hashed password
      displayName: `${firstName} ${lastName}`,
      phoneNumber,
    });

    // Add custom claims for master admin
    await auth.setCustomUserClaims(userRecord.uid, {
      role: 'master_admin',
      firstName,
      lastName,
    });

    // Generate JWT token using our utility
    const token = generateToken({
      uid: userRecord.uid,
      email: userRecord.email,
      role: 'master_admin',
    });

    res.status(201).json({
      success: true,
      data: {
        token,
        admin: {
          uid: userRecord.uid,
          email: userRecord.email,
          firstName,
          lastName,
          phoneNumber,
          role: 'master_admin',
        },
      },
    });
  } catch (error) {
    next(error);
  }
});

export default router;
