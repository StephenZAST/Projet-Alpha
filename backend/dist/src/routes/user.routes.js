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
var __rest = (this && this.__rest) || function (s, e) {
    var t = {};
    for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
        t[p] = s[p];
    if (s != null && typeof Object.getOwnPropertySymbols === "function")
        for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) {
            if (e.indexOf(p[i]) < 0 && Object.prototype.propertyIsEnumerable.call(s, p[i]))
                t[p[i]] = s[p[i]];
        }
    return t;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const auth_service_1 = require("../services/auth.service");
const auth_middleware_1 = require("../middleware/auth.middleware");
const asyncHandler_1 = require("../utils/asyncHandler");
const user_controller_1 = require("../controllers/user.controller");
const clientAffiliateLink_routes_1 = __importDefault(require("./clientAffiliateLink.routes"));
const router = express_1.default.Router();
// Protection des routes avec authentification 
router.use(auth_middleware_1.authenticateToken);
// Route pour obtenir le profil de l'utilisateur connecté
router.get('/profile', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
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
        console.error('Get profile error:', error);
        res.status(500).json({ error: error.message });
    }
})));
// Route pour créer un utilisateur par un admin
router.post('/', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    // Validation basique des champs requis
    const { email, password, firstName, lastName, phone } = req.body;
    if (!email || !password || !firstName || !lastName) {
        return res.status(400).json({
            success: false,
            error: 'Missing required fields',
            details: {
                email: !email ? 'Email is required' : null,
                password: !password ? 'Password is required' : null,
                firstName: !firstName ? 'First name is required' : null,
                lastName: !lastName ? 'Last name is required' : null
            }
        });
    }
    // Validation du format de l'email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        return res.status(400).json({
            success: false,
            error: 'Invalid email format'
        });
    }
    // Validation du mot de passe
    if (password.length < 8) {
        return res.status(400).json({
            success: false,
            error: 'Password must be at least 8 characters long'
        });
    }
    try {
        const newUser = yield auth_service_1.AuthService.register(email, password, firstName, lastName, phone, undefined, // pas de code d'affiliation pour la création par admin
        'CLIENT' // forcer le rôle CLIENT
        );
        // Masquer le mot de passe dans la réponse
        const { password: _ } = newUser, userWithoutPassword = __rest(newUser, ["password"]);
        res.status(201).json({
            success: true,
            data: userWithoutPassword
        });
    }
    catch (error) {
        if (error.message === 'Email already exists') {
            return res.status(409).json({
                success: false,
                error: 'Email already exists'
            });
        }
        throw error;
    }
})));
// Routes accessibles uniquement aux admins
router.get('/', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const users = yield auth_service_1.AuthService.getAllUsers({ page, limit });
    res.json({
        success: true,
        data: users.data,
        pagination: users.pagination
    });
})));
// Modification d'un utilisateur
router.put('/:id', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const userId = req.params.id;
    const { email, firstName, lastName, phone, role } = req.body;
    // Passe le rôle de l'utilisateur authentifié à la méthode updateUser
    const updatedUser = yield auth_service_1.AuthService.updateUser(userId, email, firstName, lastName, phone, role, { id: req.user.id, role: req.user.role });
    res.json({ success: true, data: updatedUser });
})));
// Suppression d'un utilisateur
router.delete('/:id', (0, auth_middleware_1.authorizeRoles)(['SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const targetUserId = req.params.id;
    const currentUserId = req.user.id;
    yield auth_service_1.AuthService.deleteUser(targetUserId, currentUserId);
    res.json({ success: true });
})));
// Stats des utilisateurs
router.get('/stats', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const stats = yield auth_service_1.AuthService.getUserStats();
    res.json({
        success: true,
        data: stats
    });
})));
// Ajouter cette route avant les autres routes
router.get('/search', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield user_controller_1.UserController.searchUsers(req, res);
})));
// Route pour récupérer un utilisateur par son ID
router.get('/:id', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const userId = req.params.id;
    const user = yield auth_service_1.AuthService.getUserById(userId);
    if (!user) {
        return res.status(404).json({ success: false, message: 'Utilisateur non trouvé' });
    }
    res.json({ success: true, data: user });
})));
// Note : Suppression de la route PUT /users/:userId car elle existe déjà dans auth.routes.ts
router.use(clientAffiliateLink_routes_1.default);
exports.default = router;
