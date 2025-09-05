import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { AuthService } from '../services/auth.service';
import { UserRole } from '../models/types'; 

// Type for decoded JWT token
interface DecodedToken {
  id: string;
  role: UserRole;
}

/**
 * Middleware to authenticate JWT token
 */
export const authenticateToken = (req: Request, res: Response, next: NextFunction) => {
  try {
    console.log(`[AuthMiddleware] ${req.method} ${req.path}`);
    console.log('[AuthMiddleware] Headers:', {
      authorization: req.headers['authorization'] ? 'Bearer [TOKEN_PRESENT]' : 'NO_AUTH_HEADER',
      'content-type': req.headers['content-type'],
      'user-agent': req.headers['user-agent']?.substring(0, 50) + '...'
    });
    
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      console.log('[AuthMiddleware] ❌ No token provided');
      return res.status(401).json({ error: 'Missing authentication token' });
    }

    console.log('[AuthMiddleware] ✅ Token found:', token.substring(0, 20) + '...');

    if (AuthService.isTokenBlacklisted(token)) {
      return res.status(401).json({ error: 'Token is no longer valid' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as {
      id: string;
      role: UserRole;
    };

    req.user = {
      id: decoded.id,
      userId: decoded.id,
      role: decoded.role
    };

    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
};

/**
 * Middleware to check user roles
 */
export const authorizeRoles = (allowedRoles: UserRole[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user?.role) {
      return res.status(403).json({ error: 'No role specified' });
    }

    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ 
        error: 'Access denied',
        message: 'You do not have the required permissions'
      });
    }

    next();
  };
};

/**
 * Authentication middleware for WebSocket connections
 */
export const authMiddleware = (req: Request, res: Response, next: NextFunction) => {
  if (!req.user) {
    return res.status(401).json({ error: 'Authentication required' });
  }
  next();
};
