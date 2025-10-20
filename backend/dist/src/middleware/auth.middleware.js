"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.authMiddleware = exports.authorizeRoles = exports.authenticateToken = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const auth_service_1 = require("../services/auth.service");
/**
 * Middleware to authenticate JWT token
 */
const authenticateToken = (req, res, next) => {
    var _a;
    try {
        console.log(`[AuthMiddleware] ${req.method} ${req.path}`);
        console.log('[AuthMiddleware] Headers:', {
            authorization: req.headers['authorization'] ? 'Bearer [TOKEN_PRESENT]' : 'NO_AUTH_HEADER',
            'content-type': req.headers['content-type'],
            'user-agent': ((_a = req.headers['user-agent']) === null || _a === void 0 ? void 0 : _a.substring(0, 50)) + '...'
        });
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(' ')[1];
        if (!token) {
            console.log('[AuthMiddleware] ❌ No token provided');
            return res.status(401).json({ error: 'Missing authentication token' });
        }
        console.log('[AuthMiddleware] ✅ Token found:', token.substring(0, 20) + '...');
        if (auth_service_1.AuthService.isTokenBlacklisted(token)) {
            return res.status(401).json({ error: 'Token is no longer valid' });
        }
        const decoded = jsonwebtoken_1.default.verify(token, process.env.JWT_SECRET);
        req.user = {
            id: decoded.id,
            userId: decoded.id,
            role: decoded.role
        };
        next();
    }
    catch (error) {
        return res.status(401).json({ error: 'Invalid token' });
    }
};
exports.authenticateToken = authenticateToken;
/**
 * Middleware to check user roles
 */
const authorizeRoles = (allowedRoles) => {
    return (req, res, next) => {
        var _a;
        if (!((_a = req.user) === null || _a === void 0 ? void 0 : _a.role)) {
            return res.status(403).json({ error: 'No role specified' });
        }
        if (!allowedRoles.includes(req.user.role)) {
            return res.status(403).json({
                error: 'Access denied',
                message: 'You do not have the required permissions'
            });
        }
        next();
    };
};
exports.authorizeRoles = authorizeRoles;
/**
 * Authentication middleware - same as authenticateToken but with different name
 */
const authMiddleware = (req, res, next) => {
    try {
        console.log(`[AuthMiddleware] ${req.method} ${req.path}`);
        console.log('[AuthMiddleware] Headers:', {
            authorization: req.headers['authorization'] ? 'Bearer [TOKEN_PRESENT]' : 'NO_AUTH_HEADER',
            'content-type': req.headers['content-type']
        });
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(' ')[1];
        if (!token) {
            console.log('[AuthMiddleware] ❌ No token provided');
            return res.status(401).json({ error: 'Authentication required' });
        }
        console.log('[AuthMiddleware] ✅ Token found:', token.substring(0, 20) + '...');
        if (auth_service_1.AuthService.isTokenBlacklisted(token)) {
            return res.status(401).json({ error: 'Token is no longer valid' });
        }
        const decoded = jsonwebtoken_1.default.verify(token, process.env.JWT_SECRET);
        req.user = {
            id: decoded.id,
            userId: decoded.id,
            role: decoded.role
        };
        console.log('[AuthMiddleware] ✅ User authenticated:', { id: decoded.id, role: decoded.role });
        next();
    }
    catch (error) {
        console.log('[AuthMiddleware] ❌ Token verification failed:', error);
        return res.status(401).json({ error: 'Invalid token' });
    }
};
exports.authMiddleware = authMiddleware;
