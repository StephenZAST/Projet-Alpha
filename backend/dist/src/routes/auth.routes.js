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
const express_1 = __importDefault(require("express"));
const auth_controller_1 = require("../controllers/auth.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const validators_1 = require("../middleware/validators");
const asyncHandler_1 = require("../utils/asyncHandler");
const auth_service_1 = require("../services/auth.service");
const router = express_1.default.Router();
// Routes publiques d'authentification client
router.post('/register', validators_1.validateRegistration, (0, asyncHandler_1.asyncHandler)(auth_controller_1.AuthController.register));
router.post('/login', validators_1.validateLogin, (0, asyncHandler_1.asyncHandler)(auth_controller_1.AuthController.login));
// Route d'authentification admin
router.post('/admin/login', validators_1.validateLogin, (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { email, password } = req.body;
        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password are required' });
        }
        const { user, token } = yield auth_service_1.AuthService.login(email, password);
        // Vérifier si l'utilisateur est un admin
        if (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN') {
            return res.status(403).json({ error: 'Access denied. Admin privileges required.' });
        }
        // Envoyer la réponse avec le token
        res.json({
            success: true,
            data: {
                user: {
                    id: user.id,
                    email: user.email,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    role: user.role,
                },
                token,
            },
        });
    }
    catch (error) {
        console.error('Admin login error:', error);
        res.status(401).json({
            success: false,
            error: error.message || 'Authentication failed'
        });
    }
})));
// Routes publiques (sans authentification)
router.post('/register/affiliate', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { email, password, firstName, lastName, phone, parentAffiliateCode } = req.body;
        if (!email || !password || !firstName || !lastName) {
            return res.status(400).json({ error: 'Missing required fields' });
        }
        console.log('Registering affiliate with data:', { email, firstName, lastName, phone });
        const result = yield auth_service_1.AuthService.registerAffiliate(email, password, firstName, lastName, phone, parentAffiliateCode);
        res.json(result);
    }
    catch (error) {
        console.error('Register affiliate error:', error);
        if (error.message === 'Email already exists') {
            res.status(409).json({ error: 'Email already exists' });
        }
        else {
            res.status(400).json({ error: error.message });
        }
    }
})));
// Routes de réinitialisation de mot de passe
router.post('/reset-password', (0, asyncHandler_1.asyncHandler)(auth_controller_1.AuthController.resetPassword));
router.post('/verify-code-and-reset-password', (0, asyncHandler_1.asyncHandler)(auth_controller_1.AuthController.verifyCodeAndResetPassword));
router.post('/verify-code', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { email, code } = req.body;
    const isValid = yield auth_service_1.AuthService.validateResetCode(email, code);
    if (isValid) {
        res.json({ success: true });
    }
    else {
        res.status(400).json({
            success: false,
            error: 'Code invalide ou expiré'
        });
    }
})));
// Route de vérification du token (publique mais nécessite un token)
router.get('/verify', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    try {
        const token = (_a = req.headers.authorization) === null || _a === void 0 ? void 0 : _a.replace('Bearer ', '');
        if (!token) {
            return res.status(401).json({ error: 'Token required' });
        }
        // Vérifier le token avec le service d'authentification
        const jwt = require('jsonwebtoken');
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        if (decoded) {
            res.json({ success: true, valid: true });
        }
        else {
            res.status(401).json({ error: 'Invalid token' });
        }
    }
    catch (error) {
        res.status(401).json({ error: 'Invalid token' });
    }
})));
// Routes protégées par authentification
router.use(auth_middleware_1.authenticateToken);
// Route pour obtenir l'utilisateur courant (admin)
router.get('/admin/me', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    try {
        if (!((_a = req.user) === null || _a === void 0 ? void 0 : _a.id)) {
            return res.status(401).json({ error: 'Unauthorized' });
        }
        const userData = yield auth_service_1.AuthService.getCurrentUser(req.user.id);
        res.json({
            success: true,
            data: userData
        });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
})));
// Routes authentifiées standard
router.get('/me', (0, asyncHandler_1.asyncHandler)(auth_controller_1.AuthController.getCurrentUser));
router.post('/become-affiliate', (0, asyncHandler_1.asyncHandler)(auth_controller_1.AuthController.createAffiliate));
router.patch('/update-profile', (0, asyncHandler_1.asyncHandler)(auth_controller_1.AuthController.updateProfile));
router.post('/change-password', (0, asyncHandler_1.asyncHandler)(auth_controller_1.AuthController.changePassword));
router.delete('/delete-account', (0, asyncHandler_1.asyncHandler)(auth_controller_1.AuthController.deleteAccount));
// Routes admin avec autorisation
router.get('/users', (0, auth_middleware_1.authorizeRoles)(['SUPER_ADMIN', 'ADMIN']), (0, asyncHandler_1.asyncHandler)(auth_controller_1.AuthController.getAllUsers));
router.delete('/users/:userId', (0, auth_middleware_1.authorizeRoles)(['SUPER_ADMIN', 'ADMIN']), (0, asyncHandler_1.asyncHandler)(auth_controller_1.AuthController.deleteUser));
router.patch('/users/:userId', (0, auth_middleware_1.authorizeRoles)(['SUPER_ADMIN', 'ADMIN']), (0, asyncHandler_1.asyncHandler)(auth_controller_1.AuthController.updateUser));
// Réinitialisation du mot de passe d'un utilisateur par un admin
router.post('/users/:userId/reset-password', (0, auth_middleware_1.authorizeRoles)(['SUPER_ADMIN', 'ADMIN']), (0, asyncHandler_1.asyncHandler)(auth_controller_1.AuthController.adminResetUserPassword));
// Routes super admin uniquement
router.post('/create-admin', (0, auth_middleware_1.authorizeRoles)(['SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)(auth_controller_1.AuthController.createAdmin));
// Route de déconnexion
router.post('/logout', (0, asyncHandler_1.asyncHandler)(auth_controller_1.AuthController.logout));
exports.default = router;
