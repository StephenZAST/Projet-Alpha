import { Request, Response, NextFunction } from 'express';
import { supabase } from '../../config';
import { AppError, errorCodes } from '../../utils/errors';
import { AccountCreationMethod, UserRole } from '../../models/user';

export const validateCreateUser = async (req: Request, res: Response, next: NextFunction) => {
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

  const { email, password, displayName, phoneNumber, address, affiliateCode, sponsorCode, creationMethod, profile } = req.body;

  // Vérification des champs obligatoires
  if (!email || !password || !displayName || !profile) {
    throw new AppError(400, 'Email, password, displayName, and profile are required', errorCodes.INVALID_USER_DATA);
  }

  // Vérification du format de l'email
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new AppError(400, 'Format d\'email invalide', errorCodes.INVALID_EMAIL);
  }

  // Vérification de la longueur du mot de passe
  if (password.length < 8) {
    throw new AppError(400, 'Le mot de passe doit contenir au moins 8 caractères', errorCodes.INVALID_PASSWORD);
  }

  // Vérification du format du numéro de téléphone
  if (phoneNumber && !/^\+?[0-9]{10,15}$/.test(phoneNumber)) {
    throw new AppError(400, 'Format de numéro de téléphone invalide', errorCodes.INVALID_PHONE_NUMBER);
  }

  // Vérification du champ profile
  if (!profile || typeof profile !== 'object') {
    throw new AppError(400, 'Le champ "profile" est obligatoire et doit être un objet', errorCodes.INVALID_USER_DATA);
  }

  // Vérification des champs obligatoires dans profile
  if (!profile.firstName || !profile.lastName) {
    throw new AppError(400, 'Les champs "firstName" et "lastName" sont obligatoires dans "profile"', errorCodes.INVALID_USER_DATA);
  }

  next();
};
