import express, { Request, Response, NextFunction } from 'express';
import supabase from '../../config/supabase';
import { AppError } from '../../utils/errors';
import { generateSupabaseToken } from '../../utils/auth';

const router = express.Router();

router.post('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      throw new AppError(400, 'Email and password are required', 'INVALID_CREDENTIALS');
    }

    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      throw new AppError(401, 'Invalid email or password', 'INVALID_CREDENTIALS');
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
        },
      },
    });
  } catch (error) {
    next(error);
  }
});

export default router;
