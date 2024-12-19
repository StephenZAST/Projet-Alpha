import { Request, Response, NextFunction } from 'express';
import { AppError } from '../../utils/errors';

const ERROR_CODES = {
  INVALID_USER_DATA: 'INVALID_USER_DATA',
  INVALID_EMAIL: 'INVALID_EMAIL',
  INVALID_PASSWORD: 'INVALID_PASSWORD',
  INVALID_PHONE_NUMBER: 'INVALID_PHONE_NUMBER'
};

export const validateCreateUser = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, password, displayName, phoneNumber, address, affiliateCode, sponsorCode, creationMethod, profile } = req.body;

    // Vérification des champs obligatoires
    if (!email || !password || !displayName || !profile) {
      throw new AppError(400, 'Email, password, displayName, and profile are required', ERROR_CODES.INVALID_USER_DATA);
    }

    // Vérification du format de l'email
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      throw new AppError(400, 'Format d\'email invalide', ERROR_CODES.INVALID_EMAIL);
    }

    // Vérification de la longueur du mot de passe
    if (password.length < 8) {
      throw new AppError(400, 'Le mot de passe doit contenir au moins 8 caractères', ERROR_CODES.INVALID_PASSWORD);
    }

    // Vérification du format du numéro de téléphone
    if (phoneNumber && !/^\+?[0-9]{10,15}$/.test(phoneNumber)) {
      throw new AppError(400, 'Format de numéro de téléphone invalide', ERROR_CODES.INVALID_PHONE_NUMBER);
    }

    // Vérification du champ profile
    if (!profile || typeof profile !== 'object') {
      throw new AppError(400, 'Le champ "profile" est obligatoire et doit être un objet', ERROR_CODES.INVALID_USER_DATA);
    }

    // Vérification des champs obligatoires dans profile
    if (!profile.firstName || !profile.lastName) {
      throw new AppError(400, 'Les champs "firstName" et "lastName" sont obligatoires dans "profile"', ERROR_CODES.INVALID_USER_DATA);
    }

    next();
  } catch (error) {
    next(error);
  }
};
