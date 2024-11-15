"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.authenticateUser = authenticateUser;
exports.requireAdmin = requireAdmin;
exports.requireAffiliate = requireAffiliate;
exports.requireDriver = requireDriver;
const firebase_1 = require("../services/firebase");
function authenticateUser(req, res, next) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const authHeader = req.headers.authorization;
            if (!(authHeader === null || authHeader === void 0 ? void 0 : authHeader.startsWith('Bearer '))) {
                return res.status(401).json({ error: 'Authorization header must start with Bearer' });
            }
            const token = authHeader.split('Bearer ')[1];
            if (!token) {
                return res.status(401).json({ error: 'No token provided' });
            }
            // Verify the Firebase token
            const decodedToken = yield firebase_1.auth.verifyIdToken(token);
            // Attach the decoded token to the request object
            req.user = decodedToken;
            next();
        }
        catch (error) {
            console.error('Authentication error:', error);
            return res.status(403).json({ error: 'Invalid or expired token' });
        }
    });
}
// Middleware for checking admin role
function requireAdmin(req, res, next) {
    if (!req.user || req.user.role !== 'admin') {
        return res.status(403).json({ error: 'Access denied. Admin privileges required.' });
    }
    next();
}
// Middleware for checking affiliate role
function requireAffiliate(req, res, next) {
    if (!req.user || req.user.role !== 'affiliate') {
        return res.status(403).json({ error: 'Access denied. Affiliate privileges required.' });
    }
    next();
}
function requireDriver(req, res, next) {
    if (!req.user || req.user.role !== 'driver') {
        return res.status(403).json({ error: 'Access denied. Driver privileges required.' });
    }
    next();
}
