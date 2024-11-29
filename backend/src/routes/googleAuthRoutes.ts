import express from 'express';
import { auth } from '../services/firebase';  
import { generateToken } from '../utils/auth';  
import { AppError } from '../utils/errors';

const router = express.Router();

router.post('/google-auth', async (req, res) => {
  try {
    const { idToken } = req.body;
    
    if (!idToken) {
      throw new AppError(400, 'ID token is required', 'INVALID_REQUEST');
    }

    // Verify the ID token using your existing Firebase auth
    const decodedToken = await auth.verifyIdToken(idToken);
    
    // Generate your application's JWT token using your existing method
    const token = generateToken({
      uid: String(decodedToken.uid),
      email: String(decodedToken.email),
      role: 'admin'  
    });
    
    res.json({
      token,
      user: {
        uid: decodedToken.uid,
        email: decodedToken.email,
        displayName: decodedToken.name
      }
    });
  } catch (error) {
    console.error('Google auth error:', error);
    if (error instanceof AppError) {
      res.status(error.statusCode).json({
        message: error.message
      });
    } else {
      res.status(401).json({
        code: 'GOOGLE_AUTH_FAILED',
        message: 'Failed to authenticate with Google'
      });
    }
  }
});

export default router;
