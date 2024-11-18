import { Request, Response, NextFunction } from 'express';
import { UserRole } from '../models/user';
import { AppError } from '../utils/errors';

export const hasRole = (allowedRoles: UserRole[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const userRole = req.user?.role;

    if (!userRole || !allowedRoles.includes(userRole)) {
      return next(
        new AppError(403, 'Insufficient permissions', 'FORBIDDEN')
      );
    }

    next();
  };
};
