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
    let token = req.headers.authorization;

    // Vérifier si le token existe et commence par "Bearer "
    if (token && token.startsWith('Bearer ')) {
      token = token.slice(7); // Enlever "Bearer "
    } else {
      token = req.cookies?.token; // Essayer de récupérer depuis les cookies
    }

    if (!token) {
      console.log('No token found in request:', { 
        headers: req.headers,
        cookies: req.cookies 
      });
      return res.status(401).json({ error: 'No token provided' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as any;

    // Vérifier si le token est blacklisté
    if (AuthService.isTokenBlacklisted(token)) {
      return res.status(401).json({ error: 'Token is no longer valid' });
    }

    // Vérifier si l'utilisateur existe toujours
    const user = await AuthService.getCurrentUser(decoded.id);
    if (!user) {
      return res.status(401).json({ error: 'User not found' });
    }

    req.user = decoded;
    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    return res.status(401).json({ error: 'Invalid token' });
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
