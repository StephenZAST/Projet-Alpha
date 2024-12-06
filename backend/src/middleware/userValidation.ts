import { Request, Response, NextFunction } from 'express';
import { AppError, errorCodes } from '../utils/errors';
import { AccountCreationMethod, UserRole } from '../models/user';

export const validateGetUserProfile = (req: Request, res: Response, next: NextFunction) => {
  // No specific validation needed for this route
  next();
};

export const validateUpdateProfile = (req: Request, res: Response, next: NextFunction) => {
  const { displayName, phoneNumber, email, avatar, language } = req.body;

  // Vérification du format de l'email
  if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new AppError(400, 'Format d\'email invalide', errorCodes.INVALID_EMAIL);
  }

  // Vérification du format du numéro de téléphone
  if (phoneNumber && !/^\+?[0-9]{10,15}$/.test(phoneNumber)) {
    throw new AppError(400, 'Format de numéro de téléphone invalide', errorCodes.INVALID_PHONE_NUMBER);
  }

  // Vérification de l'URL de l'avatar
  if (avatar && !/^https?:\/\/.+$/.test(avatar)) {
    throw new AppError(400, 'URL d\'avatar invalide', errorCodes.INVALID_URL);
  }

  // Vérification de la langue
  if (language && !['fr', 'en'].includes(language)) {
    throw new AppError(400, 'Langue invalide', errorCodes.INVALID_LANGUAGE);
  }

  next();
};

export const validateUpdateAddress = (req: Request, res: Response, next: NextFunction) => {
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

export const validateUpdatePreferences = (req: Request, res: Response, next: NextFunction) => {
  // No specific validation needed for this route, as preferences can be any valid JSON object
  next();
};

export const validateGetUserById = (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;

  // Vérification de l'ID
  if (!id) {
    throw new AppError(400, 'L\'ID est requis', errorCodes.INVALID_ID);
  }

  next();
};

export const validateGetUsers = (req: Request, res: Response, next: NextFunction) => {
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

export const validateCreateUser = (req: Request, res: Response, next: NextFunction) => {
  const { email, password, displayName, phoneNumber, address, affiliateCode, sponsorCode, creationMethod } = req.body;

  // Vérification des champs obligatoires
  if (!email || !password || !displayName || !address || !creationMethod) {
    throw new AppError(400, 'Tous les champs sont obligatoires', errorCodes.INVALID_USER_DATA);
  }

  // Vérification du format de l'email
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new AppError(400, 'Format d\'email invalide', errorCodes.INVALID_EMAIL);
  }

  // Vérification de la longueur du mot de passe
  if (password.length < 8) {
    throw new AppError(400, 'Le mot de passe doit contenir au moins 8 caractères', errorCodes.INVALID_PASSWORD);
  }

  // Vérification du format du numéro de téléphone
  if (phoneNumber && !/^\+?[0-9]{10,15}$/.test(phoneNumber)) {
    throw new AppError(400, 'Format de numéro de téléphone invalide', errorCodes.INVALID_PHONE_NUMBER);
  }

  // Vérification de l'adresse
  if (!address.street || !address.city || !address.postalCode || !address.country || !address.quartier || !address.location) {
    throw new AppError(400, 'L\'adresse est invalide', errorCodes.INVALID_ADDRESS_DATA);
  }

  // Vérification de la localisation
  if (!address.location.latitude || !address.location.longitude || !address.location.zoneId) {
    throw new AppError(400, 'La localisation est invalide', errorCodes.INVALID_LOCATION);
  }

  // Vérification de la méthode de création du compte
  if (!Object.values(AccountCreationMethod).includes(creationMethod)) {
    throw new AppError(400, 'Méthode de création du compte invalide', errorCodes.INVALID_ACCOUNT_CREATION_METHOD);
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

export const validateChangePassword = (req: Request, res: Response, next: NextFunction) => {
  const { oldPassword, newPassword } = req.body;

  // Vérification des champs obligatoires
  if (!oldPassword || !newPassword) {
    throw new AppError(400, 'L\'ancien et le nouveau mot de passe sont obligatoires', errorCodes.INVALID_PASSWORD_DATA);
  }

  // Vérification de la longueur du nouveau mot de passe
  if (newPassword.length < 8) {
    throw new AppError(400, 'Le nouveau mot de passe doit contenir au moins 8 caractères', errorCodes.INVALID_PASSWORD);
  }

  next();
};

export const validateResetPassword = (req: Request, res: Response, next: NextFunction) => {
  const { email } = req.body;

  // Vérification du champ obligatoire
  if (!email) {
    throw new AppError(400, 'L\'email est obligatoire', errorCodes.INVALID_EMAIL);
  }

  // Vérification du format de l'email
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new AppError(400, 'Format d\'email invalide', errorCodes.INVALID_EMAIL);
  }

  next();
};

export const validateVerifyEmail = (req: Request, res: Response, next: NextFunction) => {
  const { token } = req.body;

  // Vérification du champ obligatoire
  if (!token) {
    throw new AppError(400, 'Le token est obligatoire', errorCodes.INVALID_TOKEN);
  }

  next();
};

export const validateUpdateUserRole = (req: Request, res: Response, next: NextFunction) => {
  const { role } = req.body;

  // Vérification du champ obligatoire
  if (!role) {
    throw new AppError(400, 'Le rôle est obligatoire', errorCodes.INVALID_ROLE);
  }

  // Vérification du rôle
  if (!Object.values(UserRole).includes(role)) {
    throw new AppError(400, 'Rôle invalide', errorCodes.INVALID_ROLE);
  }

  next();
};
