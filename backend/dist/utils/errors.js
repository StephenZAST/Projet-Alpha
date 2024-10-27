"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppError = exports.errorCodes = void 0;
exports.errorCodes = {
    ARTICLE_NOT_FOUND: 'ARTICLE_NOT_FOUND',
    INVALID_ARTICLE_DATA: 'INVALID_ARTICLE_DATA',
    DATABASE_ERROR: 'DATABASE_ERROR',
    UNAUTHORIZED: 'UNAUTHORIZED',
    INVALID_PRICE_RANGE: 'INVALID_PRICE_RANGE',
    INVALID_SERVICE: 'INVALID_SERVICE',
    // Add other error codes as needed
};
class AppError extends Error {
    constructor(statusCode, message, errorCode) {
        super(message);
        this.statusCode = statusCode;
        this.errorCode = errorCode;
    }
}
exports.AppError = AppError;
