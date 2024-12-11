import { Request, Response, NextFunction } from 'express';
import { supabase } from '../config';
import { AppError } from '../utils/AppError';

export const validateAdmin = async (req: Request, res: Response, next: NextFunction) => {
  const { authorization } = req.headers;

  if (!authorization) {
    return next(new AppError('Authorization header is required', 401));
  }

  const token = authorization.split(' ')[1];

  if (!token) {
    return next(new AppError('Token is required', 401));
  }

  const { data, error } = await supabase.auth.getUser(token);

  if (error || !data?.user) {
    return next(new AppError('Invalid token', 401));
  }

  // Check if the user is an admin
  if (data.user.app_metadata?.provider !== 'admin') {
    return next(new AppError('Forbidden: User is not an admin', 403));
  }

  (req as any).user = data.user;
  next();
};
