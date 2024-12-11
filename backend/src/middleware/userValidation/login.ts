import { Request, Response, NextFunction } from 'express';
import { AppError, errorCodes } from '../../utils/errors';

export const validateLogin = (req: Request, res: Response, next: NextFunction) => {
  const { email, password } = req.body;

  // Vérification des champs obligatoires
  if (!email || !password) {
    throw new AppError(400, 'Email et mot de passe sont obligatoires', errorCodes.INVALID_CREDENTIALS);
  }

  // Vérification du format de l'email
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new AppError(400, 'Format d\'email invalide', errorCodes.INVALID_EMAIL);
  }

  next();
};
