import { Request, Response, NextFunction } from 'express';
import { AppError, errorCodes } from '../../utils/errors';

export const validateVerifyEmail = (req: Request, res: Response, next: NextFunction) => {
  const { token } = req.body;

  // Vérification du champ obligatoire
  if (!token) {
    throw new AppError(400, 'Le token est obligatoire', errorCodes.INVALID_TOKEN);
  }

  next();
};
