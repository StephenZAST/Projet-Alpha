"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorCodes = exports.AppError = void 0;
class AppError extends Error {
    constructor(statusCode, message, code) {
        super(message);
        this.statusCode = statusCode;
        this.message = message;
        this.code = code;
        Object.setPrototypeOf(this, AppError.prototype);
    }
}
exports.AppError = AppError;
exports.errorCodes = {
    ARTICLE_NOT_FOUND: 'ARTICLE_NOT_FOUND',
    INVALID_ARTICLE_DATA: 'INVALID_ARTICLE_DATA',
    DATABASE_ERROR: 'DATABASE_ERROR',
    UNAUTHORIZED: 'UNAUTHORIZED'
};
