import { Request, Response, NextFunction } from 'express';
import { AdminRole } from '../models/admin';
import { AppError, errorCodes } from '../utils/errors';

export const validateCreateAdmin = (req: Request, res: Response, next: NextFunction) => {
  const { email, password, firstName, lastName, role, phoneNumber } = req.body;

  // Vérification des champs obligatoires
  if (!email || !password || !firstName || !lastName || !role || !phoneNumber) {
    throw new AppError(400, 'Tous les champs sont obligatoires', errorCodes.INVALID_ADMIN_DATA);
  }

  // Vérification du format de l'email
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new AppError(400, 'Format d\'email invalide', errorCodes.INVALID_EMAIL);
  }

  // Vérification de la longueur du mot de passe
  if (password.length < 8) {
    throw new AppError(400, 'Le mot de passe doit contenir au moins 8 caractères', errorCodes.INVALID_PASSWORD);
  }

  // Vérification du rôle
  if (!Object.values(AdminRole).includes(role)) {
    throw new AppError(400, 'Rôle invalide', errorCodes.INVALID_ROLE);
  }

  // Vérification du format du numéro de téléphone
  if (!/^\+?[0-9]{10,15}$/.test(phoneNumber)) {
    throw new AppError(400, 'Format de numéro de téléphone invalide', errorCodes.INVALID_PHONE_NUMBER);
  }

  next();
};

export const validateUpdateAdmin = (req: Request, res: Response, next: NextFunction) => {
  const { email, password, firstName, lastName, role, phoneNumber } = req.body;

  // Vérification du format de l'email
  if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new AppError(400, 'Format d\'email invalide', errorCodes.INVALID_EMAIL);
  }

  // Vérification de la longueur du mot de passe
  if (password && password.length < 8) {
    throw new AppError(400, 'Le mot de passe doit contenir au moins 8 caractères', errorCodes.INVALID_PASSWORD);
  }

  // Vérification du rôle
  if (role && !Object.values(AdminRole).includes(role)) {
    throw new AppError(400, 'Rôle invalide', errorCodes.INVALID_ROLE);
  }

  // Vérification du format du numéro de téléphone
  if (phoneNumber && !/^\+?[0-9]{10,15}$/.test(phoneNumber)) {
    throw new AppError(400, 'Format de numéro de téléphone invalide', errorCodes.INVALID_PHONE_NUMBER);
  }

  next();
};

export const validateLogin = (req: Request, res: Response, next: NextFunction) => {
  const { email, password } = req.body;

  // Vérification des champs obligatoires
  if (!email || !password) {
    throw new AppError(400, 'Email et mot de passe sont obligatoires', errorCodes.INVALID_CREDENTIALS);
  }

  // Vérification du format de l'email
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new AppError(400, 'Format d\'email invalide', errorCodes.INVALID_EMAIL);
  }

  next();
};

export const validateToggleStatus = (req: Request, res: Response, next: NextFunction) => {
  const { isActive } = req.body;

  // Vérification du champ obligatoire
  if (typeof isActive !== 'boolean') {
    throw new AppError(400, 'Le champ "isActive" est obligatoire et doit être un booléen', errorCodes.INVALID_STATUS);
  }

  next();
};

export const validateGetAdminById = (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;

  // Vérification de l'ID
  if (!id) {
    throw new AppError(400, 'L\'ID est requis', errorCodes.INVALID_ID);
  }

  next();
};

export const validateGetAdmins = (req: Request, res: Response, next: NextFunction) => {
  const { page, limit, search } = req.query;

  // Vérification des champs de pagination
  if (page && isNaN(Number(page))) {
    throw new AppError(400, 'Le champ "page" doit être un nombre', errorCodes.INVALID_PAGINATION);
  }

  if (limit && isNaN(Number(limit))) {
    throw new AppError(400, 'Le champ "limit" doit être un nombre', errorCodes.INVALID_PAGINATION);
  }

  next();
};

export const validateDeleteAdmin = (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;

  // Vérification de l'ID
  if (!id) {
    throw new AppError(400, 'L\'ID est requis', errorCodes.INVALID_ID);
  }

  next();
};

export const validateUpdateAdminRole = (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;
  const { role } = req.body;

  // Vérification de l'ID
  if (!id) {
    throw new AppError(400, 'L\'ID est requis', errorCodes.INVALID_ID);
  }

  // Vérification du rôle
  if (!role || !Object.values(AdminRole).includes(role)) {
    throw new AppError(400, 'Rôle invalide', errorCodes.INVALID_ROLE);
  }

  next();
};
