import { Request, Response, NextFunction } from 'express';
import { AdminRole } from '../models/admin';
import { AppError, errorCodes } from '../utils/errors'; // Import errorCodes

export const validateCreateAdmin = (req: Request, res: Response, next: NextFunction) => {
    const { email, password, firstName, lastName, role, phoneNumber } = req.body;

    // Validation de base
    if (!email || !password || !firstName || !lastName || !role || !phoneNumber) {
        throw new AppError(400, 'Tous les champs sont requis', errorCodes.VALIDATION_ERROR); // Add error code
    }

    // Validation du format email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        throw new AppError(400, 'Format d\'email invalide', errorCodes.INVALID_EMAIL); // Add error code
    }

    // Validation du mot de passe
    if (password.length < 8) {
        throw new AppError(400, 'Le mot de passe doit contenir au moins 8 caractères', errorCodes.INVALID_PASSWORD); // Add error code
    }

    // Validation du rôle
    if (!Object.values(AdminRole).includes(role)) {
        throw new AppError(400, 'Rôle invalide', errorCodes.INVALID_ROLE); // Add error code
    }

    // Validation du numéro de téléphone
    const phoneRegex = /^\+?[1-9]\d{1,14}$/;
    if (!phoneRegex.test(phoneNumber)) {
        throw new AppError(400, 'Format de numéro de téléphone invalide', errorCodes.INVALID_PHONE_NUMBER); // Add error code
    }

    next();
};

export const validateUpdateAdmin = (req: Request, res: Response, next: NextFunction) => {
    const { email, password, role, phoneNumber } = req.body;

    // Validation du format email si fourni
    if (email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            throw new AppError(400, 'Format d\'email invalide', errorCodes.INVALID_EMAIL); // Add error code
        }
    }

    // Validation du mot de passe si fourni
    if (password && password.length < 8) {
        throw new AppError(400, 'Le mot de passe doit contenir au moins 8 caractères', errorCodes.INVALID_PASSWORD); // Add error code
    }

    // Validation du rôle si fourni
    if (role && !Object.values(AdminRole).includes(role)) {
        throw new AppError(400, 'Rôle invalide', errorCodes.INVALID_ROLE); // Add error code
    }

    // Validation du numéro de téléphone si fourni
    if (phoneNumber) {
        const phoneRegex = /^\+?[1-9]\d{1,14}$/;
        if (!phoneRegex.test(phoneNumber)) {
            throw new AppError(400, 'Format de numéro de téléphone invalide', errorCodes.INVALID_PHONE_NUMBER); // Add error code
        }
    }

    next();
};

export const validateLogin = (req: Request, res: Response, next: NextFunction) => {
    const { email, password } = req.body;

    if (!email || !password) {
        throw new AppError(400, 'Email et mot de passe requis', errorCodes.VALIDATION_ERROR); // Add error code
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        throw new AppError(400, 'Format d\'email invalide', errorCodes.INVALID_EMAIL); // Add error code
    }

    next();
};

export const validateToggleStatus = (req: Request, res: Response, next: NextFunction) => {
    const { isActive } = req.body;

    if (typeof isActive !== 'boolean') {
        throw new AppError(400, 'Le statut doit être un booléen', errorCodes.INVALID_STATUS); // Add error code
    }

    next();
};
