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
const auth_1 = require("../middleware/auth");
const loyalty_1 = require("../services/loyalty");
const router = express_1.default.Router();
const loyaltyService = new loyalty_1.LoyaltyService();
// Get user's loyalty account
router.get('/account', auth_1.authenticateUser, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const account = yield loyaltyService.getLoyaltyAccount(req.user.uid);
        res.json({ account });
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch loyalty account' });
    }
}));
// Get available rewards
router.get('/rewards', auth_1.authenticateUser, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const rewards = yield loyaltyService.getAvailableRewards(req.user.uid);
        res.json({ rewards });
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch rewards' });
    }
}));
// Redeem a reward
router.post('/rewards/:rewardId/redeem', auth_1.authenticateUser, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const success = yield loyaltyService.redeemReward(req.user.uid, req.params.rewardId);
        if (success) {
            res.json({ message: 'Reward redeemed successfully' });
        }
        else {
            res.status(400).json({ error: 'Failed to redeem reward' });
        }
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to redeem reward' });
    }
}));
exports.default = router;
// Admin routes for physical rewards
router.get('/admin/pending-rewards', auth_1.authenticateUser, auth_1.requireAdmin, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const pendingRewards = yield loyaltyService.getPendingPhysicalRewards();
        res.json({ pendingRewards });
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch pending rewards' });
    }
}));
router.post('/admin/claim-reward/:redemptionId', auth_1.authenticateUser, auth_1.requireAdmin, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const success = yield loyaltyService.verifyAndClaimPhysicalReward(req.params.redemptionId, req.user.uid, req.body.notes);
        if (success) {
            res.json({ message: 'Reward claimed successfully' });
        }
        else {
            res.status(400).json({ error: 'Failed to claim reward' });
        }
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to claim reward' });
    }
}));
