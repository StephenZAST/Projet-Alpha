const { AppError } = require('../../src/utils/errors');

// Middleware de gestion des erreurs
const errorHandler = (err, req, res, next) => {
    console.error('Error:', err);

    if (err instanceof AppError) {
        return res.status(err.statusCode).json({
            error: err.message,
            code: err.errorCode,
            details: err.details
        });
    }

    // Erreurs Firebase Auth
    if (err.code && err.code.startsWith('auth/')) {
        return res.status(401).json({
            error: 'Erreur d\'authentification',
            code: err.code,
            details: err.message
        });
    }

    // Erreurs Firestore
    if (err.code && err.code.startsWith('firestore/')) {
        return res.status(500).json({
            error: 'Erreur de base de données',
            code: err.code,
            details: err.message
        });
    }

    // Erreurs de validation
    if (err.name === 'ValidationError') {
        return res.status(400).json({
            error: 'Erreur de validation',
            code: 'VALIDATION_ERROR',
            details: err.details
        });
    }

    // Erreurs inconnues
    return res.status(500).json({
        error: 'Erreur interne du serveur',
        code: 'INTERNAL_SERVER_ERROR'
    });
};

// Middleware pour capturer les rejets de promesse non gérés
const unhandledRejectionHandler = (err, req, res, next) => {
    console.error('Unhandled Rejection:', err);
    res.status(500).json({
        error: 'Erreur serveur inattendue',
        code: 'UNHANDLED_REJECTION'
    });
};

// Middleware pour les routes non trouvées
const notFoundHandler = (req, res) => {
    res.status(404).json({
        error: 'Route non trouvée',
        code: 'NOT_FOUND'
    });
};

module.exports = {
    errorHandler,
    unhandledRejectionHandler,
    notFoundHandler
};
