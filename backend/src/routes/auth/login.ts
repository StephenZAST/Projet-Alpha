import express, { Request, Response, NextFunction } from 'express';
import supabase from '../../config/supabase';
import { AppError, errorCodes } from '../../utils/errors';
import { generateToken } from '../../utils/jwt';
import { UserRole } from '../../models/user';

const router = express.Router();

router.post('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return next(new AppError(400, 'Email and password are required', errorCodes.INVALID_CREDENTIALS));
    }

    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error || !data.user) {
      return next(new AppError(401, 'Invalid email or password', errorCodes.INVALID_CREDENTIALS));
    }

    // Fetch user role from the database
    const { data: userProfile, error: userProfileError } = await supabase
      .from('users')
      .select('role')
      .eq('id', data.user.id)
      .single();

    if (userProfileError) {
      return next(new AppError(500, 'Failed to fetch user profile', errorCodes.DATABASE_ERROR));
    }

    const userRole = userProfile?.role || UserRole.CLIENT;

    // Generate JWT token
    const token = generateToken({
      uid: data.user.id,
      email: data.user.email!,
      role: userRole,
    });

    res.json({
      success: true,
      data: {
        token,
        user: {
          uid: data.user.id,
          email: data.user.email,
          role: userRole
        },
      },
    });
  } catch (error) {
    next(error);
  }
});

export default router;
