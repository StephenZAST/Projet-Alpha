import { Request, Response, NextFunction } from 'express';
import { AppError, errorCodes } from '../utils/errors';
import { LoyaltyProgram } from '../models/loyalty';

export const validateCreateReward = (req: Request, res: Response, next: NextFunction) => {
  const { name, pointsRequired, discountAmount, description, expiryDate } = req.body;

  // Vérification des champs obligatoires
  if (!name || !pointsRequired || !discountAmount || !description || !expiryDate) {
    throw new AppError(400, 'Tous les champs sont obligatoires', errorCodes.INVALID_REWARD_DATA);
  }

  // Vérification des points requis
  if (isNaN(Number(pointsRequired)) || Number(pointsRequired) <= 0) {
    throw new AppError(400, 'Points requis invalides', errorCodes.INVALID_POINTS_REQUIRED);
  }

  // Vérification du montant de la réduction
  if (isNaN(Number(discountAmount)) || Number(discountAmount) <= 0) {
    throw new AppError(400, 'Montant de la réduction invalide', errorCodes.INVALID_DISCOUNT_AMOUNT);
  }

  // Vérification du format de la date d'expiration
  if (isNaN(new Date(expiryDate).getTime())) {
    throw new AppError(400, 'Date d\'expiration invalide', errorCodes.INVALID_EXPIRY_DATE);
  }

  next();
};

export const validateUpdateReward = (req: Request, res: Response, next: NextFunction) => {
  const { name, pointsRequired, discountAmount, description, expiryDate } = req.body;

  // Vérification des points requis
  if (pointsRequired !== undefined && (isNaN(Number(pointsRequired)) || Number(pointsRequired) <= 0)) {
    throw new AppError(400, 'Points requis invalides', errorCodes.INVALID_POINTS_REQUIRED);
  }

  // Vérification du montant de la réduction
  if (discountAmount !== undefined && (isNaN(Number(discountAmount)) || Number(discountAmount) <= 0)) {
    throw new AppError(400, 'Montant de la réduction invalide', errorCodes.INVALID_DISCOUNT_AMOUNT);
  }

  // Vérification du format de la date d'expiration
  if (expiryDate !== undefined && isNaN(new Date(expiryDate).getTime())) {
    throw new AppError(400, 'Date d\'expiration invalide', errorCodes.INVALID_EXPIRY_DATE);
  }

  next();
};

export const validateDeleteReward = (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;

  // Vérification de l'ID
  if (!id) {
    throw new AppError(400, 'L\'ID est requis', errorCodes.INVALID_ID);
  }

  next();
};

export const validateGetRewards = (req: Request, res: Response, next: NextFunction) => {
  const { page, limit } = req.query;

  // Vérification des champs de pagination
  if (page && isNaN(Number(page))) {
    throw new AppError(400, 'Le champ "page" doit être un nombre', errorCodes.INVALID_PAGINATION);
  }

  if (limit && isNaN(Number(limit))) {
    throw new AppError(400, 'Le champ "limit" doit être un nombre', errorCodes.INVALID_PAGINATION);
  }

  next();
};

export const validateGetRewardById = (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;

  // Vérification de l'ID
  if (!id) {
    throw new AppError(400, 'L\'ID est requis', errorCodes.INVALID_ID);
  }

  next();
};

export const validateRedeemReward = (req: Request, res: Response, next: NextFunction) => {
  const { rewardId } = req.params;

  // Vérification de l'ID de la récompense
  if (!rewardId) {
    throw new AppError(400, 'L\'ID de la récompense est requis', errorCodes.INVALID_ID);
  }

  next();
};

export const validateGetLoyaltyProgram = (req: Request, res: Response, next: NextFunction) => {
  // No specific validation needed for this route
  next();
};

export const validateUpdateLoyaltyProgram = (req: Request, res: Response, next: NextFunction) => {
  const { pointsPerEuro, welcomePoints, referralPoints } = req.body;

  // Vérification des points par euro
  if (pointsPerEuro !== undefined && (isNaN(Number(pointsPerEuro)) || Number(pointsPerEuro) <= 0)) {
    throw new AppError(400, 'Points par euro invalides', errorCodes.INVALID_POINTS_PER_EURO);
  }

  // Vérification des points de bienvenue
  if (welcomePoints !== undefined && (isNaN(Number(welcomePoints)) || Number(welcomePoints) <= 0)) {
    throw new AppError(400, 'Points de bienvenue invalides', errorCodes.INVALID_WELCOME_POINTS);
  }

  // Vérification des points de parrainage
  if (referralPoints !== undefined && (isNaN(Number(referralPoints)) || Number(referralPoints) <= 0)) {
    throw new AppError(400, 'Points de parrainage invalides', errorCodes.INVALID_REFERRAL_POINTS);
  }

  next();
};

export const validateGetUserPoints = (req: Request, res: Response, next: NextFunction) => {
  // No specific validation needed for this route
  next();
};

export const validateAdjustUserPoints = (req: Request, res: Response, next: NextFunction) => {
  const { userId } = req.params;
  const { points, reason } = req.body;

  // Vérification de l'ID de l'utilisateur
  if (!userId) {
    throw new AppError(400, 'L\'ID de l\'utilisateur est requis', errorCodes.INVALID_ID);
  }

  // Vérification des points
  if (isNaN(Number(points))) {
    throw new AppError(400, 'Points invalides', errorCodes.INVALID_POINTS);
  }

  // Vérification de la raison
  if (!reason) {
    throw new AppError(400, 'La raison est requise', errorCodes.INVALID_REASON);
  }

  next();
};

export const validateCreateLoyaltyProgram = (req: Request<{}, {}, Omit<LoyaltyProgram, 'id' | 'createdAt' | 'updatedAt'>>, res: Response, next: NextFunction) => {
  const { clientId, points, tier, referralCode, totalReferrals } = req.body;

  // Vérification des champs obligatoires
  if (!clientId || !points || !tier || !referralCode || !totalReferrals) {
    throw new AppError(400, 'Tous les champs sont obligatoires', errorCodes.INVALID_LOYALTY_DATA);
  }

  // Vérification des points
  if (isNaN(Number(points)) || Number(points) < 0) {
    throw new AppError(400, 'Points invalides', errorCodes.INVALID_POINTS);
  }

  // Vérification du total de parrainages
  if (isNaN(Number(totalReferrals)) || Number(totalReferrals) < 0) {
    throw new AppError(400, 'Total de parrainages invalide', errorCodes.INVALID_REFERRAL_POINTS);
  }

  next();
};
