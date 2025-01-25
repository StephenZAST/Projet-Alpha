import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { User } from '../models/types';
import { AuthService } from '../services/auth.service';

declare global {
  namespace Express {
    interface Request {
      user?: User;
    }
  }
}

export const authenticateToken = async (req: Request, res: Response, next: NextFunction) => {
  try {
    console.log('Auth Middleware - Headers:', req.headers);
    
    let token = req.headers.authorization;

    if (token && token.startsWith('Bearer ')) {
      token = token.slice(7);
      console.log('Extracted token:', token);
    } else {
      console.log('No Bearer token found');
      return res.status(401).json({ error: 'No token provided' });
    }

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET!) as User;
      console.log('Decoded token:', decoded);
      req.user = decoded;
      next();
    } catch (error) {
      console.error('Token verification failed:', error);
      return res.status(401).json({ error: 'Invalid token' });
    }
  } catch (error) {
    console.error('Auth middleware error:', error);
    return res.status(401).json({ error: 'Authentication failed' });
  }
};

export const authorizeRoles = (roles: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    next();
  };
};

// Export as alias for backward compatibility
export const authMiddleware = authenticateToken;
