import express, { Request, Response, NextFunction } from 'express';
import supabase from '../../config/supabase';
import { AppError, errorCodes } from '../../utils/errors';
import { generateToken } from '../../utils/jwt';
import { UserRole } from '../../models/user';

const router = express.Router();

router.post('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return next(new AppError(400, 'ID token is required', errorCodes.INVALID_TOKEN));
    }

    const { data, error } = await supabase.auth.signInWithIdToken({
        provider: 'google',
        token: idToken,
    });

    if (error || !data.user) {
      return next(new AppError(401, 'Invalid token', errorCodes.INVALID_TOKEN));
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
          role: userRole,
          displayName: data.user.user_metadata?.full_name,
        },
      },
    });
  } catch (error) {
    next(error);
  }
});

export default router;
