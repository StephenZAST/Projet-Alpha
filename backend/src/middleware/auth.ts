import { Request, Response, NextFunction } from 'express';
import { supabase } from '../config';
import { UserRole } from '../models/user';

export const authenticateUser = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { authorization } = req.headers;

    if (!authorization) {
      return res.status(401).json({ message: 'Authorization header is required' });
    }

    const token = authorization.split(' ')[1];

    if (!token) {
      return res.status(401).json({ message: 'Token is required' });
    }

    const { data, error } = await supabase.auth.getUser(token);

    if (error || !data?.user) {
      return res.status(401).json({ message: 'Invalid token' });
    }

    (req as any).user = data.user;
    next();
  } catch (error) {
    return next(error);
  }
};

export const requireAdminRolePath = (allowedRoles: UserRole[]) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = (req as any).user;

      if (!user) {
        return res.status(401).json({ message: 'User not authenticated' });
      }

      if (!allowedRoles.includes(user.role)) {
        return res.status(403).json({ message: 'Forbidden' });
      }

      next();
    } catch (error) {
      return next(error);
    }
  };
};

export const isAuthenticated = authenticateUser;
export const auth = requireAdminRolePath;
