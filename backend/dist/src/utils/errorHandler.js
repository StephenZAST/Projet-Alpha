"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createError = exports.handleError = void 0;
const handleError = (res, error) => {
    console.error('Error:', error);
    // Si l'erreur est déjà formatée (venant de Supabase par exemple)
    if (error.code && error.message) {
        res.status(getStatusCode(error.code)).json({
            success: false,
            error: {
                code: error.code,
                message: error.message,
                details: error.details
            }
        });
        return;
    }
    // Pour les erreurs génériques
    res.status(500).json({
        success: false,
        error: {
            message: error.message || 'Une erreur interne est survenue',
            code: 'INTERNAL_ERROR'
        }
    });
};
exports.handleError = handleError;
const getStatusCode = (errorCode) => {
    const statusMap = {
        'PGRST116': 404, // Not found
        'PGRST201': 403, // Forbidden
        'PGRST204': 400, // Bad request
        'P0001': 400, // PostgreSQL raise exception
        '23505': 409, // Unique violation
        '23503': 409, // Foreign key violation
        'INTERNAL_ERROR': 500
    };
    return statusMap[errorCode] || 500;
};
const createError = (message, code = 'INTERNAL_ERROR', details) => {
    return {
        code,
        message,
        details
    };
};
exports.createError = createError;
