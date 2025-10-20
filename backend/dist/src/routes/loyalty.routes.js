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
const loyalty_controller_1 = require("../controllers/loyalty.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const asyncHandler_1 = require("../utils/asyncHandler");
const router = express_1.default.Router();
// Protection des routes avec authentification
router.use(auth_middleware_1.authenticateToken);
// Routes client
router.post('/earn-points', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.earnPoints(req, res);
})));
router.post('/spend-points', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.spendPoints(req, res);
})));
router.get('/points-balance', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.getPointsBalance(req, res);
})));
// Routes admin (protection par rôle)
router.use('/admin', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']));
// Gestion des points de fidélité
router.get('/admin/points', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.getAllLoyaltyPoints(req, res);
})));
router.get('/admin/stats', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.getLoyaltyStats(req, res);
})));
router.get('/admin/users/:userId/points', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.getLoyaltyPointsByUserId(req, res);
})));
// Gestion des transactions
router.get('/admin/transactions', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.getPointTransactions(req, res);
})));
router.post('/admin/users/:userId/add-points', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.addPointsToUser(req, res);
})));
router.post('/admin/users/:userId/deduct-points', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.deductPointsFromUser(req, res);
})));
router.get('/admin/users/:userId/history', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.getUserPointHistory(req, res);
})));
// Gestion des récompenses
router.get('/admin/rewards', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.getAllRewards(req, res);
})));
router.get('/admin/rewards/:rewardId', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.getRewardById(req, res);
})));
router.post('/admin/rewards', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.createReward(req, res);
})));
router.patch('/admin/rewards/:rewardId', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.updateReward(req, res);
})));
router.delete('/admin/rewards/:rewardId', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.deleteReward(req, res);
})));
// Gestion des demandes de récompenses
router.get('/admin/claims', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.getRewardClaims(req, res);
})));
router.get('/admin/claims/pending', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.getPendingRewardClaims(req, res);
})));
router.patch('/admin/claims/:claimId/approve', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.approveRewardClaim(req, res);
})));
router.patch('/admin/claims/:claimId/reject', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.rejectRewardClaim(req, res);
})));
router.patch('/admin/claims/:claimId/use', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.markRewardClaimAsUsed(req, res);
})));
// Utilitaires
router.post('/calculate-points', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.calculateOrderPoints(req, res);
})));
router.post('/process-order-points', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield loyalty_controller_1.LoyaltyController.processOrderPoints(req, res);
})));
exports.default = router;
