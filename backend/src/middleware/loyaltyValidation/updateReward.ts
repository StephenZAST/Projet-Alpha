import { Request, Response, NextFunction } from 'express';
import { supabase } from '../../config';
import AppError from '../../utils/AppError';

export const validateUpdateReward = async (req: Request, res: Response, next: NextFunction) => {
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

  const { name, pointsRequired, discountAmount, description, expiryDate } = req.body;

  // Vérification des points requis
  if (pointsRequired !== undefined && (isNaN(Number(pointsRequired)) || Number(pointsRequired) <= 0)) {
    throw new AppError(400, 'Points requis invalides', 'INVALID_POINTS_REQUIRED');
  }

  // Vérification du montant de la réduction
  if (discountAmount !== undefined && (isNaN(Number(discountAmount)) || Number(discountAmount) <= 0)) {
    throw new AppError(400, 'Montant de la réduction invalide', 'INVALID_DISCOUNT_AMOUNT');
  }

  // Vérification du format de la date d'expiration
  if (expiryDate !== undefined && isNaN(new Date(expiryDate).getTime())) {
    throw new AppError(400, 'Date d\'expiration invalide', 'INVALID_EXPIRY_DATE');
  }

  next();
};
