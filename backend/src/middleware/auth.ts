import { Request, Response, NextFunction } from 'express';
import { supabase } from '../config/supabase';
import { UserRole } from '../models/user';
import { AppError, errorCodes } from '../utils/errors';

export const authenticateUser = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { authorization } = req.headers;

    if (!authorization) {
      return next(new AppError(401, 'Authorization header is required', errorCodes.UNAUTHORIZED));
    }

    const token = authorization.split(' ')[1];

    if (!token) {
      return next(new AppError(401, 'Token is required', errorCodes.UNAUTHORIZED));
    }

    const { data, error } = await supabase.auth.getUser(token);

    if (error || !data?.user) {
      return next(new AppError(401, 'Invalid token', errorCodes.UNAUTHORIZED));
    }

    // Fetch user role from the database
    const { data: userProfile, error: userProfileError } = await supabase
      .from('users')
      .select('role, firstName, lastName')
      .eq('id', data.user.id)
      .single();

    if (userProfileError) {
      return next(new AppError(500, 'Failed to fetch user profile', errorCodes.DATABASE_ERROR));
    }

    (req as any).user = {
      ...data.user,
      role: userProfile.role,
      firstName: userProfile.firstName,
      lastName: userProfile.lastName
    };
    next();
  } catch (error) {
    next(error);
  }
};

export const requireAdminRolePath = (allowedRoles: UserRole[]) => {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const user = (req as any).user;

      if (!user) {
        return next(new AppError(401, 'User not authenticated', errorCodes.UNAUTHORIZED));
      }

      if (!allowedRoles.includes(user.role)) {
        return next(new AppError(403, 'Forbidden', errorCodes.FORBIDDEN));
      }

      next();
    } catch (error) {
      next(error);
    }
  };
};

export const isAuthenticated = authenticateUser;
export const auth = requireAdminRolePath;
