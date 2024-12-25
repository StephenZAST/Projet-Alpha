import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { User } from '../models/types';

declare global {
  namespace Express {
    interface Request {
      user?: User;
    }
  }
}

export const authenticateToken = (req: Request, res: Response, next: NextFunction) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Authentication required' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as any;
    req.user = {
      id: decoded.id,  // Assurez-vous que cela correspond au payload JWT
      role: decoded.role,
      // Ajoutez d'autres champs requis par l'interface User
      email: decoded.email || '',
      password: decoded.password || '',
      firstName: decoded.firstName || '',
      lastName: decoded.lastName || '',
      createdAt: new Date(decoded.createdAt || new Date()),
      updatedAt: new Date(decoded.updatedAt || new Date())
    };
    
    console.log('Decoded token:', decoded);
    console.log('Set user:', req.user);
    console.log('Token payload:', req.user); // Ajoutez ce log
    next();
  } catch (error) {
    console.error('Token verification error:', error);
    return res.status(403).json({ error: 'Invalid token' });
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
