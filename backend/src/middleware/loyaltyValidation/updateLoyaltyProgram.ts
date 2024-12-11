import { Request, Response, NextFunction } from 'express';
import { supabase } from '../../config';
import AppError from '../../utils/AppError';

export const validateUpdateLoyaltyProgram = async (req: Request, res: Response, next: NextFunction) => {
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

  const { pointsPerEuro, welcomePoints, referralPoints } = req.body;

  // Vérification des points par euro
  if (pointsPerEuro !== undefined && (isNaN(Number(pointsPerEuro)) || Number(pointsPerEuro) < 0)) {
    throw new AppError(400, 'Points par euro invalides', 'INVALID_POINTS_PER_EURO');
  }

  // Vérification des points de bienvenue
  if (welcomePoints !== undefined && (isNaN(Number(welcomePoints)) || Number(welcomePoints) < 0)) {
    throw new AppError(400, 'Points de bienvenue invalides', 'INVALID_WELCOME_POINTS');
  }

  // Vérification des points de parrainage
  if (referralPoints !== undefined && (isNaN(Number(referralPoints)) || Number(referralPoints) < 0)) {
    throw new AppError(400, 'Points de parrainage invalides', 'INVALID_REFERRAL_POINTS');
  }

  next();
};
