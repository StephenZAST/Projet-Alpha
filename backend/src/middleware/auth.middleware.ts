import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { User } from '../models/types';
import { AuthService } from '../services/auth.service';

declare global {
  namespace Express {
    interface Request {
      user?: Partial<User>;
    }
  }
}

const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) {
  throw new Error('JWT_SECRET must be defined');
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
      const decoded = jwt.verify(token, JWT_SECRET) as { id: string; role: string };
      
      if (!decoded || !decoded.id || !decoded.role) {
        console.error('Invalid token payload');
        return res.status(401).json({ error: 'Invalid token payload' });
      }

      console.log('Decoded token:', decoded);
      
      // Only set the fields we know exist in the token
      req.user = {
        id: decoded.id,
        role: decoded.role as User['role']
      };

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

export const authorizeRoles = (allowedRoles: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      console.log('User role:', req.user?.role);
      console.log('Allowed roles:', allowedRoles);
      
      if (!req.user || !req.user.role) {
        console.log('No user or role found in request');
        return res.status(401).json({ error: 'Unauthorized' });
      }

      if (!allowedRoles.includes(req.user.role)) {
        console.log(`User role ${req.user.role} not in allowed roles:`, allowedRoles);
        return res.status(403).json({ error: 'Insufficient permissions' });
      }

      next();
    } catch (error) {
      console.error('Authorization error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  };
};

// Export as alias for backward compatibility
export const authMiddleware = authenticateToken;
