class AppError extends Error {
    constructor(message, statusCode = 500, errorCode = 'INTERNAL_SERVER_ERROR', details = null) {
        super(message);
        this.statusCode = statusCode;
        this.errorCode = errorCode;
        this.details = details;
        this.name = 'AppError';

        Error.captureStackTrace(this, this.constructor);
    }
}

// Erreurs d'authentification
class AuthenticationError extends AppError {
    constructor(message = 'Non authentifié', details = null) {
        super(message, 401, 'AUTHENTICATION_ERROR', details);
        this.name = 'AuthenticationError';
    }
}

// Erreurs d'autorisation
class AuthorizationError extends AppError {
    constructor(message = 'Non autorisé', details = null) {
        super(message, 403, 'AUTHORIZATION_ERROR', details);
        this.name = 'AuthorizationError';
    }
}

// Erreurs de validation
class ValidationError extends AppError {
    constructor(message = 'Données invalides', details = null) {
        super(message, 400, 'VALIDATION_ERROR', details);
        this.name = 'ValidationError';
    }
}

// Erreurs de ressource non trouvée
class NotFoundError extends AppError {
    constructor(message = 'Ressource non trouvée', details = null) {
        super(message, 404, 'NOT_FOUND_ERROR', details);
        this.name = 'NotFoundError';
    }
}

// Erreurs de conflit
class ConflictError extends AppError {
    constructor(message = 'Conflit de ressources', details = null) {
        super(message, 409, 'CONFLICT_ERROR', details);
        this.name = 'ConflictError';
    }
}

// Erreurs de limite de taux
class RateLimitError extends AppError {
    constructor(message = 'Trop de requêtes', details = null) {
        super(message, 429, 'RATE_LIMIT_ERROR', details);
        this.name = 'RateLimitError';
    }
}

// Erreurs de service externe
class ExternalServiceError extends AppError {
    constructor(message = 'Erreur de service externe', details = null) {
        super(message, 502, 'EXTERNAL_SERVICE_ERROR', details);
        this.name = 'ExternalServiceError';
    }
}

// Erreurs de base de données
class DatabaseError extends AppError {
    constructor(message = 'Erreur de base de données', details = null) {
        super(message, 500, 'DATABASE_ERROR', details);
        this.name = 'DatabaseError';
    }
}

module.exports = {
    AppError,
    AuthenticationError,
    AuthorizationError,
    ValidationError,
    NotFoundError,
    ConflictError,
    RateLimitError,
    ExternalServiceError,
    DatabaseError
};
