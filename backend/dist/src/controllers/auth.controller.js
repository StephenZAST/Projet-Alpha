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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const auth_service_1 = require("../services/auth.service");
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const generateToken = (user) => {
    return jsonwebtoken_1.default.sign({
        id: user.id,
        role: user.role, // S'assurer que le rôle est inclus
        email: user.email
    }, process.env.JWT_SECRET, { expiresIn: '7d' });
};
class AuthController {
    static register(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { email, password, firstName, lastName, phone, affiliateCode, role } = req.body;
                const result = yield auth_service_1.AuthService.register(email, password, firstName, lastName, phone, affiliateCode, role);
                res.json({ data: result });
            }
            catch (error) {
                console.error('Registration error:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
    static login(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const { email, password } = req.body;
                console.log('Login request received:', { email, password }); // Ajoutez ce log
                if (!email || !password) {
                    return res.status(400).json({ error: 'Email and password are required' });
                }
                const { user, token } = yield auth_service_1.AuthService.login(email, password);
                // Définir le cookie avec le token
                res.cookie('token', token, {
                    httpOnly: true,
                    secure: process.env.NODE_ENV === 'production',
                    sameSite: 'strict',
                    maxAge: 24 * 60 * 60 * 1000 // 24 heures
                });
                // Récupérer l'utilisateur avec ses adresses
                const userData = yield auth_service_1.AuthService.getCurrentUser(user.id);
                const userAddresses = ((_a = userData.addresses) === null || _a === void 0 ? void 0 : _a.filter(addr => addr.userId === userData.id)) || [];
                // Envoyer la réponse
                res.json({
                    success: true,
                    data: {
                        user: userData,
                        token: token,
                        addresses: userAddresses // Envoyer uniquement les adresses de l'utilisateur
                    }
                });
            }
            catch (error) {
                console.error('Login error:', error); // Ajoutez ce log
                res.status(401).json({
                    success: false,
                    error: error.message || 'Authentication failed'
                });
            }
        });
    }
    static getCurrentUser(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                console.log('req.user in AuthController:', req.user);
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield auth_service_1.AuthService.getCurrentUser(userId);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static createAffiliate(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield auth_service_1.AuthService.createAffiliate(userId);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getAllUsers(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield auth_service_1.AuthService.getAllUsers({});
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static createAdmin(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const { email, password, firstName, lastName, phone } = req.body;
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield auth_service_1.AuthService.createAdmin(email, password, firstName, lastName, phone);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static updateProfile(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const { email, firstName, lastName, phone } = req.body;
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield auth_service_1.AuthService.updateProfile(userId, email, firstName, lastName, phone);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static changePassword(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const { currentPassword, newPassword } = req.body;
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield auth_service_1.AuthService.changePassword(userId, currentPassword, newPassword);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static deleteAccount(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield auth_service_1.AuthService.deleteAccount(userId);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static deleteUser(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                const targetUserId = req.params.userId;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield auth_service_1.AuthService.deleteUser(targetUserId, userId);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static updateUser(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const { email, firstName, lastName, phone, role } = req.body;
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                const targetUserId = req.params.userId;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield auth_service_1.AuthService.updateUser(targetUserId, email, firstName, lastName, phone, role);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static logout(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // Simplifier la logique de déconnexion
                res.clearCookie('token');
                res.json({ success: true, message: 'Logged out successfully' });
            }
            catch (error) {
                console.error('Logout error:', error);
                res.status(400).json({ error: error.message });
            }
        });
    }
    static resetPassword(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { email } = req.body;
                console.log('Attempting password reset for email:', email);
                yield auth_service_1.AuthService.resetPassword(email);
                console.log('Password reset email sent successfully');
                res.json({ message: 'Password reset email sent' });
            }
            catch (error) {
                console.error('Reset password error:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
    static verifyCodeAndResetPassword(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { email, code, newPassword } = req.body;
                console.log('Reset password request received for:', email);
                yield auth_service_1.AuthService.verifyCodeAndResetPassword(email, code, newPassword);
                // Test immédiat de connexion
                try {
                    const { user, token } = yield auth_service_1.AuthService.login(email, newPassword);
                    console.log('Test login successful with new password');
                    res.json({
                        success: true,
                        message: 'Password reset and verified successfully',
                        data: { user, token }
                    });
                }
                catch (loginError) {
                    console.error('Test login failed:', loginError);
                    res.status(400).json({
                        success: false,
                        error: 'Password reset succeeded but verification failed'
                    });
                }
            }
            catch (error) {
                console.error('Password reset failed:', error);
                res.status(400).json({
                    success: false,
                    error: error.message
                });
            }
        });
    }
    static adminResetUserPassword(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { userId } = req.params;
                // Générer un mot de passe temporaire sécurisé
                const tempPassword = Math.random().toString(36).slice(-10) + Math.floor(1000 + Math.random() * 9000);
                // Mettre à jour le mot de passe de l'utilisateur
                const user = yield auth_service_1.AuthService.adminResetUserPassword(userId, tempPassword);
                res.json({
                    success: true,
                    data: {
                        user: {
                            id: user.id,
                            email: user.email,
                            firstName: user.firstName,
                            lastName: user.lastName,
                            phone: user.phone,
                            role: user.role
                        },
                        tempPassword
                    }
                });
            }
            catch (error) {
                res.status(500).json({ success: false, error: error.message });
            }
        });
    }
}
exports.AuthController = AuthController;
