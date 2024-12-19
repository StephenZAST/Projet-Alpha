import { Request, Response, NextFunction } from 'express';
import { supabase } from '../../config/supabase';
import { AppError, errorCodes } from '../../utils/errors';
import { AccountCreationMethod, UserRole } from '../../models/user';

export const validateUpdateProfile = async (req: Request, res: Response, next: NextFunction) => {
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

  const { displayName, phoneNumber, email, avatar, language } = req.body;

  // Vérification du format de l'email
  if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new AppError(400, 'Format d\'email invalide', errorCodes.INVALID_EMAIL);
  }

  // Vérification du format du numéro de téléphone
  if (phoneNumber && !/^\+?[0-9]{10,15}$/.test(phoneNumber)) {
    throw new AppError(400, 'Format de numéro de téléphone invalide', errorCodes.INVALID_PHONE_NUMBER);
  }

  // Vérification de l'URL de l'avatar
  if (avatar && !/^https?:\/\/.+$/.test(avatar)) {
    throw new AppError(400, 'URL d\'avatar invalide', errorCodes.INVALID_URL);
  }

  // Vérification de la langue
  if (language && !['fr', 'en'].includes(language)) {
    throw new AppError(400, 'Langue invalide', errorCodes.INVALID_LANGUAGE);
  }

  next();
};
