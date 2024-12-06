import { Request, Response, NextFunction } from 'express';
import { AppError, errorCodes } from '../utils/errors';
import { OrderStatus } from '../models/order';

export const validateCreateOrder = (req: Request, res: Response, next: NextFunction) => {
  const { items, totalAmount, shippingAddress, billingAddress, paymentMethod } = req.body;

  // Vérification des champs obligatoires
  if (!items || !totalAmount || !shippingAddress || !paymentMethod) {
    throw new AppError(400, 'Tous les champs sont obligatoires', errorCodes.INVALID_ORDER_DATA);
  }

  // Vérification des items
  if (!Array.isArray(items) || items.length === 0) {
    throw new AppError(400, 'La liste des items est invalide', errorCodes.INVALID_ITEMS);
  }

  // Vérification du montant total
  if (isNaN(Number(totalAmount)) || Number(totalAmount) <= 0) {
    throw new AppError(400, 'Montant total invalide', errorCodes.INVALID_AMOUNT);
  }

  // Vérification de l'adresse de livraison
  if (!shippingAddress.street || !shippingAddress.city || !shippingAddress.postalCode || !shippingAddress.country) {
    throw new AppError(400, 'Adresse de livraison invalide', errorCodes.INVALID_ADDRESS_DATA);
  }

  // Vérification de l'adresse de facturation (si fournie)
  if (billingAddress && (!billingAddress.street || !billingAddress.city || !billingAddress.postalCode || !billingAddress.country)) {
    throw new AppError(400, 'Adresse de facturation invalide', errorCodes.INVALID_ADDRESS_DATA);
  }

  next();
};

export const validateGetOrders = (req: Request, res: Response, next: NextFunction) => {
  const { page, limit, status, userId, startDate, endDate } = req.query;

  // Vérification des champs de pagination
  if (page && isNaN(Number(page))) {
    throw new AppError(400, 'Le champ "page" doit être un nombre', errorCodes.INVALID_PAGINATION);
  }

  if (limit && isNaN(Number(limit))) {
    throw new AppError(400, 'Le champ "limit" doit être un nombre', errorCodes.INVALID_PAGINATION);
  }

  // Vérification du statut
  if (status && !Object.values(OrderStatus).includes(status as OrderStatus)) {
    throw new AppError(400, 'Statut invalide', errorCodes.INVALID_STATUS);
  }

  // Vérification des dates
  if (startDate && isNaN(new Date(startDate as string).getTime())) {
    throw new AppError(400, 'Date de début invalide', errorCodes.INVALID_DATE);
  }

  if (endDate && isNaN(new Date(endDate as string).getTime())) {
    throw new AppError(400, 'Date de fin invalide', errorCodes.INVALID_DATE);
  }

  next();
};

export const validateGetOrderById = (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;

  // Vérification de l'ID
  if (!id) {
    throw new AppError(400, 'L\'ID est requis', errorCodes.INVALID_ID);
  }

  next();
};

export const validateUpdateOrderStatus = (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;
  const { status } = req.body;

  // Vérification de l'ID
  if (!id) {
    throw new AppError(400, 'L\'ID est requis', errorCodes.INVALID_ID);
  }

  // Vérification du statut
  if (!status || !Object.values(OrderStatus).includes(status)) {
    throw new AppError(400, 'Statut invalide', errorCodes.INVALID_STATUS);
  }

  next();
};

export const validateAssignDeliveryPerson = (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;
  const { deliveryPersonId } = req.body;

  // Vérification de l'ID
  if (!id) {
    throw new AppError(400, 'L\'ID est requis', errorCodes.INVALID_ID);
  }

  // Vérification de l'ID du livreur
  if (!deliveryPersonId) {
    throw new AppError(400, 'L\'ID du livreur est requis', errorCodes.INVALID_ID);
  }

  next();
};

export const validateUpdateOrder = (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;
  const { items, totalAmount, shippingAddress, billingAddress, paymentMethod } = req.body;

  // Vérification de l'ID
  if (!id) {
    throw new AppError(400, 'L\'ID est requis', errorCodes.INVALID_ID);
  }

  // Vérification des items
  if (items && (!Array.isArray(items) || items.length === 0)) {
    throw new AppError(400, 'La liste des items est invalide', errorCodes.INVALID_ITEMS);
  }

  // Vérification du montant total
  if (totalAmount !== undefined && (isNaN(Number(totalAmount)) || Number(totalAmount) <= 0)) {
    throw new AppError(400, 'Montant total invalide', errorCodes.INVALID_AMOUNT);
  }

  // Vérification de l'adresse de livraison
  if (shippingAddress && (!shippingAddress.street || !shippingAddress.city || !shippingAddress.postalCode || !shippingAddress.country)) {
    throw new AppError(400, 'Adresse de livraison invalide', errorCodes.INVALID_ADDRESS_DATA);
  }

  // Vérification de l'adresse de facturation (si fournie)
  if (billingAddress && (!billingAddress.street || !billingAddress.city || !billingAddress.postalCode || !billingAddress.country)) {
    throw new AppError(400, 'Adresse de facturation invalide', errorCodes.INVALID_ADDRESS_DATA);
  }

  next();
};

export const validateCancelOrder = (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;

  // Vérification de l'ID
  if (!id) {
    throw new AppError(400, 'L\'ID est requis', errorCodes.INVALID_ID);
  }

  next();
};

export const validateGetOrderHistory = (req: Request, res: Response, next: NextFunction) => {
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

export const validateRateOrder = (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;
  const { rating, comment } = req.body;

  // Vérification de l'ID
  if (!id) {
    throw new AppError(400, 'L\'ID est requis', errorCodes.INVALID_ID);
  }

  // Vérification de la note
  if (rating === undefined || isNaN(Number(rating)) || Number(rating) < 1 || Number(rating) > 5) {
    throw new AppError(400, 'Note invalide', errorCodes.INVALID_RATING);
  }

  next();
};
