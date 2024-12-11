import { Request, Response, NextFunction } from 'express';
import { supabase } from '../../config';
import AppError from '../../utils/AppError';

export const validateAdjustUserPoints = async (req: Request, res: Response, next: NextFunction) => {
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

  const { userId } = req.params;
  const { points, reason } = req.body;

  // Vérification de l'ID de l'utilisateur
  if (!userId) {
    throw new AppError(400, 'L\'ID de l\'utilisateur est requis', 'INVALID_ID');
  }

  // Vérification des points
  if (isNaN(Number(points))) {
    throw new AppError(400, 'Points invalides', 'INVALID_POINTS');
  }

  // Vérification de la raison
  if (!reason) {
    throw new AppError(400, 'La raison est requise', 'INVALID_REASON');
  }

  next();
};
