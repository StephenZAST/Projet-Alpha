import express, { Request, Response, NextFunction } from 'express';
import supabase from '../../config/supabase';
import { AppError } from '../../utils/errors';
import { generateSupabaseToken } from '../../utils/auth';

const router = express.Router();

router.post('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      throw new AppError(400, 'ID token is required', 'INVALID_TOKEN');
    }

    const { data, error } = await supabase.auth.signInWithIdToken({
        provider: 'google',
        token: idToken,
    });

    if (error) {
      throw new AppError(401, 'Invalid token', 'INVALID_TOKEN');
    }

    // Generate JWT token using our utility
    const token = generateSupabaseToken(data.user);

    res.json({
      success: true,
      data: {
        token,
        user: {
          uid: data.user.id,
          email: data.user.email,
          role: data.user.role || 'user',
          displayName: data.user.user_metadata?.full_name,
        },
      },
    });
  } catch (error) {
    next(error);
  }
});

export default router;
