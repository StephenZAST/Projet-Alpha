import { Request, Response, NextFunction } from 'express';
import { auth } from '../services/firebase';
import { DecodedIdToken } from 'firebase-admin/auth';

// Extend Express Request type to include user information
declare global {
  namespace Express {
    interface Request {
      user?: DecodedIdToken;
    }
  }
}

export async function authenticateUser(req: Request, res: Response, next: NextFunction) {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader?.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Authorization header must start with Bearer' });
    }

    const token = authHeader.split('Bearer ')[1];
    
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    // Verify the Firebase token
    const decodedToken = await auth.verifyIdToken(token);
    
    // Attach the decoded token to the request object
    req.user = decodedToken;
    
    next();
  } catch (error) {
    console.error('Authentication error:', error);
    return res.status(403).json({ error: 'Invalid or expired token' });
  }
}

// Middleware for checking admin role
export function requireAdmin(req: Request, res: Response, next: NextFunction) {
  if (!req.user || req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Access denied. Admin privileges required.' });
  }
  next();
}

// Middleware for checking affiliate role
export function requireAffiliate(req: Request, res: Response, next: NextFunction) {
  if (!req.user || req.user.role !== 'affiliate') {
    return res.status(403).json({ error: 'Access denied. Affiliate privileges required.' });
  }
  next();
}

export function requireDriver(req: Request, res: Response, next: NextFunction) {
  if (!req.user || req.user.role !== 'driver') {
    return res.status(403).json({ error: 'Access denied. Driver privileges required.' });
  }
  next();
}
