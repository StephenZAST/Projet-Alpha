"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifyToken = exports.generateToken = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const generateToken = (user) => {
    try {
        return jsonwebtoken_1.default.sign({
            id: user.id,
            email: user.email,
            role: user.role,
            firstName: user.first_name,
            lastName: user.last_name,
        }, process.env.JWT_SECRET || 'your-secret-key', {
            expiresIn: '24h', // Token expire après 24h
        });
    }
    catch (error) {
        console.error('Error generating token:', error);
        throw new Error('Failed to generate authentication token');
    }
};
exports.generateToken = generateToken;
const verifyToken = (token) => {
    try {
        const decoded = jsonwebtoken_1.default.verify(token, process.env.JWT_SECRET || 'your-secret-key');
        return decoded;
    }
    catch (error) {
        console.error('Error verifying token:', error);
        throw new Error('Invalid authentication token');
    }
};
exports.verifyToken = verifyToken;
