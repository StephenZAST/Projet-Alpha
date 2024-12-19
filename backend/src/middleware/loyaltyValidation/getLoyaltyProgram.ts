import { Request, Response, NextFunction } from 'express';
import { supabase } from '../../config/supabase';
import AppError from '../../utils/AppError';

export const validateGetLoyaltyProgram = async (req: Request, res: Response, next: NextFunction) => {
  const { authorization } = req.headers;

  if (!authorization) {
    return next(new AppError(401, 'Authorization header is required', 'UNAUTHORIZED'));
  }

  const token = authorization.split(' ')[1];

  if (!token) {
    return next(new AppError(401, 'Token is required', 'UNAUTHORIZED'));
  }

  const { data, error } = await supabase.auth.getUser(token);

  if (error || !data?.user) {
    return next(new AppError(401, 'Invalid token', 'UNAUTHORIZED'));
  }

  (req as any).user = data.user;

  // No specific validation needed for this route
  next();
};
