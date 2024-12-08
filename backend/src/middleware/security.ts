import helmet from 'helmet';
import cors from 'cors';
import express, { Express, Request, Response, NextFunction } from 'express'; // Import express
import { AppError, errorCodes } from '../utils/errors'; // Import errorCodes

// Configuration CORS
const corsOptions = {
    origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    exposedHeaders: ['Content-Range', 'X-Content-Range'],
    credentials: true,
    maxAge: 600 // 10 minutes
};

// Configuration Helmet
const helmetConfig = {
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            scriptSrc: ["'self'", "'unsafe-inline'"],
            styleSrc: ["'self'", "'unsafe-inline'"],
            imgSrc: ["'self'", 'data:', 'https:'],
            connectSrc: ["'self'"],
            fontSrc: ["'self'"],
            objectSrc: ["'none'"],
            mediaSrc: ["'self'"],
            frameSrc: ["'none'"]
        }
    },
    crossOriginEmbedderPolicy: true,
    crossOriginOpenerPolicy: true,
    crossOriginResourcePolicy: true,
    dnsPrefetchControl: true,
    frameguard: true,
    hidePoweredBy: true,
    hsts: true,
    ieNoOpen: true,
    noSniff: true,
    originAgentCluster: true,
    permittedCrossDomainPolicies: true,
    referrerPolicy: true,
    xssFilter: true
};

// Middleware pour vérifier les en-têtes de sécurité
const securityHeadersCheck = (req: Request, res: Response, next: NextFunction) => {
    const requiredHeaders = ['x-content-type-options', 'x-frame-options', 'x-xss-protection'];
    const missingHeaders = requiredHeaders.filter(header => !res.getHeader(header));

    if (missingHeaders.length > 0) {
        console.warn(`Missing security headers: ${missingHeaders.join(', ')}`);
    }

    next();
};

// Middleware pour valider le contenu JSON
const validateJsonContent = (err: any, req: Request, res: Response, next: NextFunction) => {
    if (err instanceof SyntaxError && 'body' in err) {
        throw new AppError(400, 'Invalid JSON payload', errorCodes.INVALID_JSON);
    }
    next();
};

// Middleware pour nettoyer les données d'entrée
const sanitizeInput = (req: Request, res: Response, next: NextFunction) => {
    if (req.body) {
        Object.keys(req.body).forEach(key => {
            if (typeof req.body[key] === 'string') {
                // Supprimer les caractères dangereux
                req.body[key] = req.body[key]
                    .replace(/[<>]/g, '')
                    .trim();
            }
        });
    }
    next();
};

// Configuration de la sécurité de l'application
export const configureSecurityMiddleware = (app: Express) => {
    // Appliquer Helmet avec la configuration personnalisée
    app.use(helmet(helmetConfig));

    // Appliquer CORS avec la configuration personnalisée
    app.use(cors(corsOptions));

    // Middleware de validation JSON
    app.use(validateJsonContent);

    // Middleware de nettoyage des entrées
    app.use(sanitizeInput);

    // Vérification des en-têtes de sécurité
    app.use(securityHeadersCheck);

    // Désactiver les informations sensibles dans les en-têtes
    app.disable('x-powered-by');

    // Limiter la taille des payloads
    app.use(express.json({ limit: '10kb' })); // Use imported express
    app.use(express.urlencoded({ extended: true, limit: '10kb' })); // Use imported express

    // Ajouter des en-têtes de sécurité supplémentaires
    app.use((req: Request, res: Response, next: NextFunction) => {
        res.setHeader('X-Content-Security-Policy', "default-src 'self'");
        res.setHeader('X-Download-Options', 'noopen');
        res.setHeader('X-Permitted-Cross-Domain-Policies', 'none');
        res.setHeader('X-Content-Type-Options', 'nosniff');
        next();
    });
};

// Middleware pour vérifier l'origine des requêtes
export const checkOrigin = (req: Request, res: Response, next: NextFunction) => {
    const origin = req.get('origin');
    if (!origin || !corsOptions.origin.includes(origin)) {
        throw new AppError(403, 'Origin not allowed', errorCodes.FORBIDDEN_ORIGIN);
    }
    next();
};

// Middleware pour vérifier les méthodes HTTP autorisées
export const checkMethod = (req: Request, res: Response, next: NextFunction) => {
    if (!corsOptions.methods.includes(req.method)) {
        throw new AppError(405, 'Method not allowed', errorCodes.METHOD_NOT_ALLOWED);
    }
    next();
};
