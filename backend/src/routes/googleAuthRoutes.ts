import express from 'express';
import supabase from '../config/supabase';
import { generateToken } from '../utils/jwt';
import { AppError } from '../utils/errors';
import { UserRole } from '../models/user';

const router = express.Router();

router.post('/google-auth', async (req, res) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      throw new AppError(400, 'ID token is required', 'INVALID_REQUEST');
    }

    const { data: userResponse, error: authError } = await supabase.auth.getUser(idToken);

    if (authError || !userResponse) {
      console.error('Supabase auth error:', authError);
      throw new AppError(401, 'Failed to authenticate with Google', 'GOOGLE_AUTH_FAILED');
    }
    const user = userResponse.user;
    if (!user) {
      throw new AppError(401, 'Failed to authenticate with Google', 'GOOGLE_AUTH_FAILED');
    }

    // Fetch user role from the database
    const { data: userProfile, error: userProfileError } = await supabase
      .from('users')
      .select('role')
      .eq('id', user.id)
      .single();

    if (userProfileError) {
      throw new AppError(500, 'Failed to fetch user profile', 'DATABASE_ERROR');
    }

    const userRole = userProfile?.role || UserRole.CLIENT;

    const token = generateToken({
      uid: user.id,
      email: user.email!,
      role: userRole,
    });

    res.json({
      token,
      user: {
        uid: user.id,
        email: user.email,
        name: user.user_metadata.full_name
      }
    });
  } catch (error) {
    console.error('Google auth error:', error);
    if (error instanceof AppError) {
      res.status(error.statusCode).json({
        message: error.message,
        code: error.errorCode,
      });
    } else {
      res.status(500).json({
        code: 'GOOGLE_AUTH_FAILED',
        message: 'Failed to authenticate with Google'
      });
    }
  }
});

export default router;
