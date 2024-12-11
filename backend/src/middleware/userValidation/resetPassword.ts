import { Request, Response, NextFunction } from 'express';
import { AppError, errorCodes } from '../../utils/errors';

export const validateResetPassword = (req: Request, res: Response, next: NextFunction) => {
  const { email } = req.body;

  // Vérification du champ obligatoire
  if (!email) {
    throw new AppError(400, 'L\'email est obligatoire', errorCodes.INVALID_EMAIL);
  }

  // Vérification du format de l'email
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new AppError(400, 'Format d\'email invalide', errorCodes.INVALID_EMAIL);
  }

  next();
};
