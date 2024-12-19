import { Request, Response, NextFunction } from 'express';
import { supabase } from '../../config/supabase';
import AppError from '../../utils/AppError';

export const validateGetRewardById = async (req: Request, res: Response, next: NextFunction) => {
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

  const { id } = req.params;

  // Vérification de l'ID
  if (!id) {
    throw new AppError(400, 'L\'ID est requis', 'INVALID_ID');
  }

  next();
};
