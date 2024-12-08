import rateLimit from 'express-rate-limit';
import { Request, Response } from 'express';
import { AppError, errorCodes } from './errors';

// Configuration de base pour le rate limiting
const baseConfig = {
    windowMs: 15 * 60 * 1000, // 15 minutes
    standardHeaders: true,
    legacyHeaders: false,
    handler: (req: Request, res: Response) => {
        throw new AppError(429, 'Too many requests from this IP, please try again later', errorCodes.RATE_LIMIT_EXCEEDED);
    }
};

// Rate limiter pour l'API générale
export const apiLimiter = rateLimit({
    ...baseConfig,
    max: 100 // Limite à 100 requêtes par fenêtre
});

// Rate limiter plus strict pour l'authentification
export const authLimiter = rateLimit({
    ...baseConfig,
    max: 5, // Limite à 5 tentatives par heure
    windowMs: 60 * 60 * 1000 // 1 heure
});

// Rate limiter pour les opérations sensibles (ex: création d'admin)
export const sensitiveOpsLimiter = rateLimit({
    ...baseConfig,
    windowMs: 60 * 60 * 1000, // 1 heure
    max: 10 // Limite à 10 requêtes par heure
});

// Rate limiter pour les webhooks
export const webhookLimiter = rateLimit({
    ...baseConfig,
    windowMs: 1 * 60 * 1000, // 1 minute
    max: 30 // Limite à 30 requêtes par minute
});

// Rate limiter pour l'API publique
export const publicApiLimiter = rateLimit({
    ...baseConfig,
    max: 50 // Limite à 50 requêtes par fenêtre
});

// Rate limiter pour les requêtes de recherche
export const searchLimiter = rateLimit({
    ...baseConfig,
    windowMs: 5 * 60 * 1000, // 5 minutes
    max: 30 // Limite à 30 requêtes par 5 minutes
});

// Rate limiter pour les opérations en masse
export const bulkOpsLimiter = rateLimit({
    ...baseConfig,
    windowMs: 60 * 60 * 1000, // 1 heure
    max: 20 // Limite à 20 requêtes par heure
});

// Rate limiter dynamique basé sur le rôle de l'utilisateur
export const createDynamicRateLimiter = (maxRequests: number, windowMs: number = 15 * 60 * 1000) => {
    return rateLimit({
        ...baseConfig,
        windowMs,
        max: maxRequests
    });
};
