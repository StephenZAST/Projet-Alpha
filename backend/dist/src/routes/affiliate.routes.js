"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const affiliate_controller_1 = require("../controllers/affiliate.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const debug_middleware_1 = require("../middleware/debug.middleware");
const affiliateLink_routes_1 = __importDefault(require("./affiliateLink.routes"));
const router = (0, express_1.Router)();
// Ajouter le middleware de debug en développement
if (process.env.NODE_ENV !== 'production') {
    router.use(debug_middleware_1.debugMiddleware);
}
// Middleware pour vérifier les droits admin
const adminCheck = (req, res, next) => {
    var _a, _b;
    if (((_a = req.user) === null || _a === void 0 ? void 0 : _a.role) !== 'ADMIN' && ((_b = req.user) === null || _b === void 0 ? void 0 : _b.role) !== 'SUPER_ADMIN') {
        return res.status(403).json({ error: 'Admin access required' });
    }
    next();
};
// Routes pour les affiliés
router.get('/profile', auth_middleware_1.authMiddleware, affiliate_controller_1.AffiliateController.getProfile);
router.post('/create-profile', auth_middleware_1.authMiddleware, affiliate_controller_1.AffiliateController.createProfile);
router.put('/profile', auth_middleware_1.authMiddleware, affiliate_controller_1.AffiliateController.updateProfile);
router.get('/commissions', auth_middleware_1.authMiddleware, affiliate_controller_1.AffiliateController.getCommissions);
router.post('/withdrawal', auth_middleware_1.authMiddleware, affiliate_controller_1.AffiliateController.requestWithdrawal);
router.get('/referrals', auth_middleware_1.authMiddleware, affiliate_controller_1.AffiliateController.getReferrals);
router.get('/levels', affiliate_controller_1.AffiliateController.getLevels);
router.get('/current-level', auth_middleware_1.authMiddleware, affiliate_controller_1.AffiliateController.getCurrentLevel);
router.post('/generate-code', auth_middleware_1.authMiddleware, affiliate_controller_1.AffiliateController.generateAffiliateCode);
// Routes d'administration
router.get('/admin/list', auth_middleware_1.authenticateToken, adminCheck, affiliate_controller_1.AffiliateController.getAllAffiliates);
router.get('/admin/stats', auth_middleware_1.authenticateToken, adminCheck, affiliate_controller_1.AffiliateController.getAffiliateStats);
router.get('/admin/withdrawals/pending', auth_middleware_1.authenticateToken, adminCheck, affiliate_controller_1.AffiliateController.getPendingWithdrawals);
router.get('/admin/withdrawals', auth_middleware_1.authenticateToken, adminCheck, affiliate_controller_1.AffiliateController.getWithdrawals);
router.patch('/admin/withdrawals/:withdrawalId/reject', auth_middleware_1.authenticateToken, adminCheck, affiliate_controller_1.AffiliateController.rejectWithdrawal);
router.patch('/admin/withdrawals/:withdrawalId/approve', auth_middleware_1.authenticateToken, adminCheck, affiliate_controller_1.AffiliateController.approveWithdrawal);
router.patch('/admin/affiliates/:affiliateId/status', auth_middleware_1.authenticateToken, adminCheck, affiliate_controller_1.AffiliateController.updateAffiliateStatus);
// Création d'un client avec code affilié
router.post('/register-with-code', affiliate_controller_1.AffiliateController.createCustomerWithAffiliateCode);
// Routes pour les liens d'affiliation
router.use(affiliateLink_routes_1.default);
exports.default = router;
