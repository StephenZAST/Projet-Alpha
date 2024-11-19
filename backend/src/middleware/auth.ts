import { Request, Response, NextFunction } from 'express';
import { auth as firebaseAuth } from '../config/firebase'; // Rename imported auth to firebaseAuth
import { User, UserRole } from '../models/user';

declare global {
  namespace Express {
    interface Request {
      user?: User;
      token?: string;
    }
  }
}

export const isAuthenticated = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const token = authHeader.split('Bearer ')[1];
    const decodedToken = await firebaseAuth.verifyIdToken(token); // Use firebaseAuth here
    
    if (!decodedToken) {
      return res.status(401).json({ error: 'Invalid token' });
    }

    req.user = {
      id: decodedToken.uid,
      email: decodedToken.email || '',
      firstName: decodedToken.name?.split(' ')[0] || '',
      lastName: decodedToken.name?.split(' ')[1] || '',
      phoneNumber: decodedToken.phone_number || '',
      role: decodedToken.role as UserRole || UserRole.CLIENT,
      emailVerified: decodedToken.email_verified || false,
    } as User;
    
    req.token = token;
    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    res.status(401).json({ error: 'Authentication failed' });
  }
};

export const authenticateUser = isAuthenticated;
export const authMiddleware = isAuthenticated; // Rename to authMiddleware

export const requireRole = (roles: UserRole[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ 
        error: 'Insufficient permissions',
        required: roles,
        current: req.user.role
      });
    }

    next();
  };
};

export const requireAdminRole = requireRole([UserRole.SUPER_ADMIN]);
export const requireSuperAdmin = requireRole([UserRole.SUPER_ADMIN]);
export const requireServiceClient = requireRole([UserRole.SERVICE_CLIENT, UserRole.SUPER_ADMIN]);
export const requireSecretaire = requireRole([UserRole.SECRETAIRE, UserRole.SUPER_ADMIN]);
export const requireLivreur = requireRole([UserRole.LIVREUR, UserRole.SUPER_ADMIN]);
export const requireSuperviseur = requireRole([UserRole.SUPERVISEUR, UserRole.SUPER_ADMIN]);

export const requireOwnership = (getUserId: (req: Request) => string) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const resourceUserId = getUserId(req);
    
    if (req.user.id !== resourceUserId && req.user.role !== UserRole.SUPER_ADMIN) {
      return res.status(403).json({ error: 'Access denied. You can only access your own resources.' });
    }

    next();
  };
};

export const validateOneClickOrder = (req: Request, res: Response, next: NextFunction) => {
  if (!req.user) {
    return res.status(401).json({ error: 'Authentication required for one-click orders.' });
  }

  next();
};
