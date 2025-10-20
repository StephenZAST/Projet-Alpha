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
exports.LoyaltyController = void 0;
const loyalty_service_1 = require("../services/loyalty.service");
const loyaltyAdmin_service_1 = require("../services/loyaltyAdmin.service");
class LoyaltyController {
    static earnPoints(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const { points, source, referenceId } = req.body;
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield loyalty_service_1.LoyaltyService.earnPoints(userId, points, source, referenceId);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static spendPoints(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const { points, source, referenceId } = req.body;
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield loyalty_service_1.LoyaltyService.spendPoints(userId, points, source, referenceId);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getPointsBalance(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield loyalty_service_1.LoyaltyService.getPointsBalance(userId);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    // Routes admin
    static getAllLoyaltyPoints(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const page = parseInt(req.query.page) || 1;
                const limit = parseInt(req.query.limit) || 10;
                const query = req.query.query;
                const result = yield loyaltyAdmin_service_1.LoyaltyAdminService.getAllLoyaltyPoints({ page, limit, query });
                res.json({ success: true, data: result });
            }
            catch (error) {
                console.error('[LoyaltyController] Error getting all loyalty points:', error);
                res.status(500).json({ success: false, error: error.message });
            }
        });
    }
    static getLoyaltyStats(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const result = yield loyaltyAdmin_service_1.LoyaltyAdminService.getLoyaltyStats();
                res.json({ success: true, data: result });
            }
            catch (error) {
                console.error('[LoyaltyController] Error getting loyalty stats:', error);
                res.status(500).json({ success: false, error: error.message });
            }
        });
    }
    static getLoyaltyPointsByUserId(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { userId } = req.params;
                const result = yield loyaltyAdmin_service_1.LoyaltyAdminService.getLoyaltyPointsByUserId(userId);
                res.json({ success: true, data: result });
            }
            catch (error) {
                console.error('[LoyaltyController] Error getting loyalty points by user ID:', error);
                res.status(500).json({ success: false, error: error.message });
            }
        });
    }
    static getPointTransactions(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const page = parseInt(req.query.page) || 1;
                const limit = parseInt(req.query.limit) || 10;
                const userId = req.query.userId;
                const type = req.query.type;
                const source = req.query.source;
                const result = yield loyaltyAdmin_service_1.LoyaltyAdminService.getPointTransactions({
                    page,
                    limit,
                    userId,
                    type,
                    source,
                });
                res.json({ success: true, data: result });
            }
            catch (error) {
                console.error('[LoyaltyController] Error getting point transactions:', error);
                res.status(500).json({ success: false, error: error.message });
            }
        });
    }
    static addPointsToUser(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { userId } = req.params;
                const { points, source, referenceId } = req.body;
                const result = yield loyaltyAdmin_service_1.LoyaltyAdminService.addPointsToUser(userId, points, source, referenceId);
                res.json({ success: true, data: result });
            }
            catch (error) {
                console.error('[LoyaltyController] Error adding points to user:', error);
                res.status(500).json({ success: false, error: error.message });
            }
        });
    }
    static deductPointsFromUser(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { userId } = req.params;
                const { points, source, referenceId } = req.body;
                const result = yield loyaltyAdmin_service_1.LoyaltyAdminService.deductPointsFromUser(userId, points, source, referenceId);
                res.json({ success: true, data: result });
            }
            catch (error) {
                console.error('[LoyaltyController] Error deducting points from user:', error);
                res.status(500).json({ success: false, error: error.message });
            }
        });
    }
    static getUserPointHistory(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { userId } = req.params;
                const page = parseInt(req.query.page) || 1;
                const limit = parseInt(req.query.limit) || 10;
                const result = yield loyaltyAdmin_service_1.LoyaltyAdminService.getUserPointHistory(userId, { page, limit });
                res.json({ success: true, data: result });
            }
            catch (error) {
                console.error('[LoyaltyController] Error getting user point history:', error);
                res.status(500).json({ success: false, error: error.message });
            }
        });
    }
    // Gestion des récompenses
    static getAllRewards(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const page = parseInt(req.query.page) || 1;
                const limit = parseInt(req.query.limit) || 10;
                const isActive = req.query.isActive === 'true' ? true : req.query.isActive === 'false' ? false : undefined;
                const type = req.query.type;
                console.log('🎯 [LoyaltyController] getAllRewards called with:', { page, limit, isActive, type });
                const result = yield loyaltyAdmin_service_1.LoyaltyAdminService.getAllRewards({ page, limit, isActive, type });
                console.log('📤 [LoyaltyController] Sending response with', result.data.length, 'rewards');
                if (result.data.length > 0) {
                    console.log('📤 [LoyaltyController] First reward in response:', {
                        id: result.data[0].id,
                        name: result.data[0].name,
                        pointsCost: result.data[0].pointsCost,
                        discountValue: result.data[0].discountValue,
                    });
                }
                res.json({ success: true, data: result });
            }
            catch (error) {
                console.error('[LoyaltyController] Error getting all rewards:', error);
                res.status(500).json({ success: false, error: error.message });
            }
        });
    }
    static getRewardById(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { rewardId } = req.params;
                const result = yield loyaltyAdmin_service_1.LoyaltyAdminService.getRewardById(rewardId);
                res.json({ success: true, data: result });
            }
            catch (error) {
                console.error('[LoyaltyController] Error getting reward by ID:', error);
                res.status(500).json({ success: false, error: error.message });
            }
        });
    }
    static createReward(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const rewardData = req.body;
                const result = yield loyaltyAdmin_service_1.LoyaltyAdminService.createReward(rewardData);
                res.status(201).json({ success: true, data: result });
            }
            catch (error) {
                console.error('[LoyaltyController] Error creating reward:', error);
                res.status(500).json({ success: false, error: error.message });
            }
        });
    }
    static updateReward(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { rewardId } = req.params;
                const updateData = req.body;
                const result = yield loyaltyAdmin_service_1.LoyaltyAdminService.updateReward(rewardId, updateData);
                res.json({ success: true, data: result });
            }
            catch (error) {
                console.error('[LoyaltyController] Error updating reward:', error);
                res.status(500).json({ success: false, error: error.message });
            }
        });
    }
    static deleteReward(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { rewardId } = req.params;
                yield loyaltyAdmin_service_1.LoyaltyAdminService.deleteReward(rewardId);
                res.json({ success: true, message: 'Reward deleted successfully' });
            }
            catch (error) {
                console.error('[LoyaltyController] Error deleting reward:', error);
                res.status(500).json({ success: false, error: error.message });
            }
        });
    }
    // Gestion des demandes de récompenses
    static getRewardClaims(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const page = parseInt(req.query.page) || 1;
                const limit = parseInt(req.query.limit) || 10;
                const status = req.query.status;
                const userId = req.query.userId;
                const rewardId = req.query.rewardId;
                const result = yield loyaltyAdmin_service_1.LoyaltyAdminService.getRewardClaims({
                    page,
                    limit,
                    status,
                    userId,
                    rewardId,
                });
                res.json({ success: true, data: result });
            }
            catch (error) {
                console.error('[LoyaltyController] Error getting reward claims:', error);
                res.status(500).json({ success: false, error: error.message });
            }
        });
    }
    static getPendingRewardClaims(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const page = parseInt(req.query.page) || 1;
                const limit = parseInt(req.query.limit) || 10;
                const result = yield loyaltyAdmin_service_1.LoyaltyAdminService.getPendingRewardClaims({ page, limit });
                res.json({ success: true, data: result });
            }
            catch (error) {
                console.error('[LoyaltyController] Error getting pending reward claims:', error);
                res.status(500).json({ success: false, error: error.message });
            }
        });
    }
    static approveRewardClaim(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { claimId } = req.params;
                yield loyaltyAdmin_service_1.LoyaltyAdminService.approveRewardClaim(claimId);
                res.json({ success: true, message: 'Reward claim approved successfully' });
            }
            catch (error) {
                console.error('[LoyaltyController] Error approving reward claim:', error);
                res.status(500).json({ success: false, error: error.message });
            }
        });
    }
    static rejectRewardClaim(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { claimId } = req.params;
                const { reason } = req.body;
                yield loyaltyAdmin_service_1.LoyaltyAdminService.rejectRewardClaim(claimId, reason);
                res.json({ success: true, message: 'Reward claim rejected successfully' });
            }
            catch (error) {
                console.error('[LoyaltyController] Error rejecting reward claim:', error);
                res.status(500).json({ success: false, error: error.message });
            }
        });
    }
    static markRewardClaimAsUsed(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { claimId } = req.params;
                yield loyaltyAdmin_service_1.LoyaltyAdminService.markRewardClaimAsUsed(claimId);
                res.json({ success: true, message: 'Reward claim marked as used successfully' });
            }
            catch (error) {
                console.error('[LoyaltyController] Error marking reward claim as used:', error);
                res.status(500).json({ success: false, error: error.message });
            }
        });
    }
    // Utilitaires
    static calculateOrderPoints(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { orderAmount } = req.body;
                const points = Math.floor(orderAmount * 0.01); // 1 point par FCFA
                res.json({ success: true, data: { points } });
            }
            catch (error) {
                console.error('[LoyaltyController] Error calculating order points:', error);
                res.status(500).json({ success: false, error: error.message });
            }
        });
    }
    static processOrderPoints(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { userId, orderId, orderAmount } = req.body;
                const points = Math.floor(orderAmount * 0.01);
                const result = yield loyalty_service_1.LoyaltyService.earnPoints(userId, points, 'ORDER', orderId);
                res.json({ success: true, data: result });
            }
            catch (error) {
                console.error('[LoyaltyController] Error processing order points:', error);
                res.status(500).json({ success: false, error: error.message });
            }
        });
    }
}
exports.LoyaltyController = LoyaltyController;
