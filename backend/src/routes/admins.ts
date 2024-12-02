import express from 'express';
import { authService } from '../services/auth.service';
import { generateToken } from '../utils/auth';

const router = express.Router();

// Create Master Admin
router.post('/master/create', async (req, res, next) => {
  try {
    const { email, password, firstName, lastName, phoneNumber } = req.body;

    const admin = await authService.createMasterAdmin({
      email,
      password,
      firstName,
      lastName,
      phoneNumber
    });

    // Generate JWT token
    const token = generateToken({
      uid: admin.uid,
      email: admin.email,
      role: 'master_admin'
    });

    res.status(201).json({
      success: true,
      data: {
        token,
        admin: {
          uid: admin.uid,
          email: admin.email,
          firstName: admin.firstName,
          lastName: admin.lastName,
          role: 'master_admin'
        }
      }
    });
  } catch (error) {
    next(error);
  }
});

export default router;
