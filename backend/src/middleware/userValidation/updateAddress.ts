import { Request, Response, NextFunction } from 'express';
import { supabase } from '../../config';
import { AppError, errorCodes } from '../../utils/errors';

export const validateUpdateAddress = async (req: Request, res: Response, next: NextFunction) => {
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

  const { street, city, postalCode, country, quartier, location, additionalInfo } = req.body;

  // Vérification des champs obligatoires
  if (!street || !city || !postalCode || !country || !quartier || !location) {
    throw new AppError(400, 'Tous les champs sont obligatoires', errorCodes.INVALID_ADDRESS_DATA);
  }

  // Vérification de la localisation
  if (!location.latitude || !location.longitude || !location.zoneId) {
    throw new AppError(400, 'La localisation est invalide', errorCodes.INVALID_LOCATION);
  }

  next();
};
