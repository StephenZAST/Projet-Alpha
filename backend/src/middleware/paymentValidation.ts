import { Request, Response, NextFunction } from 'express';
import { AppError, errorCodes } from '../utils/errors';

export const validateGetPaymentMethods = (req: Request, res: Response, next: NextFunction) => {
  // No specific validation needed for this route
  next();
};

export const validateAddPaymentMethod = (req: Request, res: Response, next: NextFunction) => {
  const { paymentMethodId, cardNumber, expiryDate, cvv } = req.body;

  // Vérification des champs obligatoires
  if (!paymentMethodId || !cardNumber || !expiryDate || !cvv) {
    throw new AppError(400, 'Tous les champs sont obligatoires', errorCodes.INVALID_PAYMENT_DATA);
  }

  // Vérification du format du numéro de carte
  if (!/^\d{16}$/.test(cardNumber)) {
    throw new AppError(400, 'Numéro de carte invalide', errorCodes.INVALID_CARD_NUMBER);
  }

  // Vérification du format de la date d'expiration
  if (!/^(0[1-9]|1[0-2])\/\d{2}$/.test(expiryDate)) {
    throw new AppError(400, 'Date d\'expiration invalide', errorCodes.INVALID_EXPIRY_DATE);
  }

  // Vérification du format du CVV
  if (!/^\d{3,4}$/.test(cvv)) {
    throw new AppError(400, 'CVV invalide', errorCodes.INVALID_CVV);
  }

  next();
};

export const validateRemovePaymentMethod = (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;

  // Vérification de l'ID
  if (!id) {
    throw new AppError(400, 'L\'ID est requis', errorCodes.INVALID_ID);
  }

  next();
};

export const validateSetDefaultPaymentMethod = (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;

  // Vérification de l'ID
  if (!id) {
    throw new AppError(400, 'L\'ID est requis', errorCodes.INVALID_ID);
  }

  next();
};

export const validateProcessPayment = (req: Request, res: Response, next: NextFunction) => {
  const { amount, currency, paymentMethodId } = req.body;

  // Vérification des champs obligatoires
  if (!amount || !currency || !paymentMethodId) {
    throw new AppError(400, 'Tous les champs sont obligatoires', errorCodes.INVALID_PAYMENT_DATA);
  }

  // Vérification du montant
  if (isNaN(Number(amount)) || Number(amount) <= 0) {
    throw new AppError(400, 'Montant invalide', errorCodes.INVALID_AMOUNT);
  }

  next();
};

export const validateProcessRefund = (req: Request, res: Response, next: NextFunction) => {
  const { paymentId, amount, reason } = req.body;

  // Vérification des champs obligatoires
  if (!paymentId || !amount || !reason) {
    throw new AppError(400, 'Tous les champs sont obligatoires', errorCodes.INVALID_REFUND_DATA);
  }

  // Vérification du montant
  if (isNaN(Number(amount)) || Number(amount) <= 0) {
    throw new AppError(400, 'Montant invalide', errorCodes.INVALID_AMOUNT);
  }

  next();
};

export const validateGetPaymentHistory = (req: Request, res: Response, next: NextFunction) => {
  const { page, limit, status } = req.query;

  // Vérification des champs de pagination
  if (page && isNaN(Number(page))) {
    throw new AppError(400, 'Le champ "page" doit être un nombre', errorCodes.INVALID_PAGINATION);
  }

  if (limit && isNaN(Number(limit))) {
    throw new AppError(400, 'Le champ "limit" doit être un nombre', errorCodes.INVALID_PAGINATION);
  }

  next();
};
