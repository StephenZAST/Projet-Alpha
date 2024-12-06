import { Request, Response, NextFunction } from 'express';
import { AppError, errorCodes } from '../utils/errors';
import { RecurringFrequency } from '../types/recurring';

export const validateCreateRecurringOrder = (req: Request, res: Response, next: NextFunction) => {
  const { frequency, baseOrder } = req.body;

  // Vérification des champs obligatoires
  if (!frequency || !baseOrder) {
    throw new AppError(400, 'Tous les champs sont obligatoires', errorCodes.INVALID_RECURRING_ORDER_DATA);
  }

  // Vérification de la fréquence
  if (!Object.values(RecurringFrequency).includes(frequency)) {
    throw new AppError(400, 'Fréquence invalide', errorCodes.INVALID_FREQUENCY);
  }

  // Vérification de la commande de base
  if (!baseOrder.items || !baseOrder.address || !baseOrder.preferences) {
    throw new AppError(400, 'La commande de base est invalide', errorCodes.INVALID_BASE_ORDER);
  }

  next();
};

export const validateUpdateRecurringOrder = (req: Request, res: Response, next: NextFunction) => {
  const { frequency, baseOrder, isActive } = req.body;

  // Vérification de la fréquence
  if (frequency && !Object.values(RecurringFrequency).includes(frequency)) {
    throw new AppError(400, 'Fréquence invalide', errorCodes.INVALID_FREQUENCY);
  }

  // Vérification de la commande de base
  if (baseOrder && (!baseOrder.items || !baseOrder.address || !baseOrder.preferences)) {
    throw new AppError(400, 'La commande de base est invalide', errorCodes.INVALID_BASE_ORDER);
  }

  // Vérification du statut actif
  if (isActive !== undefined && typeof isActive !== 'boolean') {
    throw new AppError(400, 'Le statut actif est invalide', errorCodes.INVALID_ACTIVE_STATUS);
  }

  next();
};

export const validateCancelRecurringOrder = (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;

  // Vérification de l'ID
  if (!id) {
    throw new AppError(400, 'L\'ID est requis', errorCodes.INVALID_ID);
  }

  next();
};

export const validateGetRecurringOrders = (req: Request, res: Response, next: NextFunction) => {
  const { page, limit, status } = req.query;

  // Vérification des champs de pagination
  if (page && isNaN(Number(page))) {
    throw new AppError(400, 'Le champ "page" doit être un nombre', errorCodes.INVALID_PAGINATION);
  }

  if (limit && isNaN(Number(limit))) {
    throw new AppError(400, 'Le champ "limit" doit être un nombre', errorCodes.INVALID_PAGINATION);
  }

  // Vérification du statut
  if (status && !['active', 'cancelled', 'paused'].includes(status as string)) {
    throw new AppError(400, 'Statut invalide', errorCodes.INVALID_STATUS);
  }

  next();
};

export const validateProcessRecurringOrders = (req: Request, res: Response, next: NextFunction) => {
  // No specific validation needed for this route
  next();
};
