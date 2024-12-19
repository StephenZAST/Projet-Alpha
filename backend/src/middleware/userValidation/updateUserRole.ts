import { Request, Response, NextFunction } from 'express';
import { supabase } from '../../config/supabase';
import { AppError, errorCodes } from '../../utils/errors';
import { UserRole } from '../../models/user';

export const validateUpdateUserRole = async (req: Request, res: Response, next: NextFunction) => {
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

  (req as any).user = data.user;

  const { role } = req.body;

  // Vérification du champ obligatoire
  if (!role) {
    throw new AppError(400, 'Le rôle est obligatoire', errorCodes.INVALID_ROLE);
  }

  // Vérification du rôle
  if (!Object.values(UserRole).includes(role)) {
    throw new AppError(400, 'Rôle invalide', errorCodes.INVALID_ROLE);
  }

  next();
};
