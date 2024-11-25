import { Request, Response, NextFunction } from 'express';
import { UserRole } from '../models/user';
import { AppError, errorCodes } from '../utils/errors';

export const hasRole = (roles: UserRole | UserRole[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = req.user;

    if (!user || !user.role) {
      return next(new AppError(401, 'Unauthorized', errorCodes.UNAUTHORIZED));
    }

    // Handle both single role and array of roles
    const rolesToCheck = Array.isArray(roles) ? roles : [roles];

    if (rolesToCheck.includes(user.role)) {
      next();
    } else {
      return next(new AppError(403, 'Forbidden', errorCodes.FORBIDDEN));
    }
  };
};
