import { Request, Response, NextFunction } from 'express';
import { supabase } from '../../config/supabase';
import AppError from '../../utils/AppError';
import { LoyaltyProgram } from '../../models/loyalty';

export const validateCreateLoyaltyProgram = async (req: Request, res: Response, next: NextFunction) => {
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

  const { clientId, points, tier, referralCode, totalReferrals } = req.body;

  // Vérification des champs obligatoires
  if (!clientId || !points || !tier || !referralCode || !totalReferrals) {
    throw new AppError(400, 'Tous les champs sont obligatoires', 'INVALID_LOYALTY_DATA');
  }

  // Vérification des points
  if (isNaN(Number(points)) || Number(points) < 0) {
    throw new AppError(400, 'Points invalides', 'INVALID_POINTS');
  }

  // Vérification du total de parrainages
  if (isNaN(Number(totalReferrals)) || Number(totalReferrals) < 0) {
    throw new AppError(400, 'Total de parrainages invalide', 'INVALID_REFERRAL_POINTS');
  }

  next();
};
