import { Request, Response, NextFunction } from 'express';
import { supabase } from '../../config/supabase';
import { AppError, errorCodes } from '../../utils/errors';

export const validateChangePassword = async (req: Request, res: Response, next: NextFunction) => {
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

  const { oldPassword, newPassword } = req.body;

  // Vérification des champs obligatoires
  if (!oldPassword || !newPassword) {
    throw new AppError(400, 'L\'ancien et le nouveau mot de passe sont obligatoires', errorCodes.INVALID_PASSWORD_DATA);
  }

  // Vérification de la longueur du nouveau mot de passe
  if (newPassword.length < 8) {
    throw new AppError(400, 'Le nouveau mot de passe doit contenir au moins 8 caractères', errorCodes.INVALID_PASSWORD);
  }

  next();
};
