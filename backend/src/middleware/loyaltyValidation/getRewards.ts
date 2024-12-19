import { Request, Response, NextFunction } from 'express';
import { supabase } from '../../config/supabase';
import AppError from '../../utils/AppError';

export const validateGetRewards = async (req: Request, res: Response, next: NextFunction) => {
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

  const { page, limit } = req.query;

  // Vérification des champs de pagination
  if (page && isNaN(Number(page))) {
    throw new AppError(400, 'Le champ "page" doit être un nombre', 'INVALID_PAGINATION');
  }

  if (limit && isNaN(Number(limit))) {
    throw new AppError(400, 'Le champ "limit" doit être un nombre', 'INVALID_PAGINATION');
  }

  next();
};
