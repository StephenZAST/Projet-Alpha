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
exports.LoyaltyService = void 0;
const firebase_1 = require("./firebase");
const loyalty_1 = require("../models/loyalty");
const notifications_1 = require("./notifications");
class LoyaltyService {
    constructor() {
        this.loyaltyRef = firebase_1.db.collection('loyalty_accounts');
        this.rewardsRef = firebase_1.db.collection('rewards');
        this.redemptionsRef = firebase_1.db.collection('reward_redemptions');
        this.notificationService = new notifications_1.NotificationService();
    }
    calculateTier(points) {
        return __awaiter(this, void 0, void 0, function* () {
            if (points >= 10001)
                return loyalty_1.LoyaltyTier.PLATINUM;
            if (points >= 5001)
                return loyalty_1.LoyaltyTier.GOLD;
            if (points >= 1001)
                return loyalty_1.LoyaltyTier.SILVER;
            return loyalty_1.LoyaltyTier.BRONZE;
        });
    }
    addPoints(userId, points, reason) {
        return __awaiter(this, void 0, void 0, function* () {
            const accountRef = this.loyaltyRef.doc(userId);
            const account = yield accountRef.get();
            let updatedAccount;
            yield firebase_1.db.runTransaction((transaction) => __awaiter(this, void 0, void 0, function* () {
                if (!account.exists) {
                    updatedAccount = {
                        userId,
                        points: points,
                        lifetimePoints: points,
                        tier: yield this.calculateTier(points),
                        lastUpdated: new Date()
                    };
                    transaction.set(accountRef, updatedAccount);
                }
                else {
                    const currentAccount = account.data();
                    const newPoints = currentAccount.points + points;
                    const newLifetimePoints = currentAccount.lifetimePoints + points;
                    const newTier = yield this.calculateTier(newLifetimePoints);
                    updatedAccount = Object.assign(Object.assign({}, currentAccount), { points: newPoints, lifetimePoints: newLifetimePoints, tier: newTier, lastUpdated: new Date() });
                    transaction.update(accountRef, {
                        points: updatedAccount.points,
                        lifetimePoints: updatedAccount.lifetimePoints,
                        tier: updatedAccount.tier,
                        lastUpdated: updatedAccount.lastUpdated
                    });
                }
            }));
            // Send notification about points earned
            yield this.notificationService.sendLoyaltyPointsReminder(userId, points);
            return updatedAccount;
        });
    }
    redeemReward(userId, rewardId) {
        return __awaiter(this, void 0, void 0, function* () {
            const rewardRef = this.rewardsRef.doc(rewardId);
            const accountRef = this.loyaltyRef.doc(userId);
            try {
                let redemptionId;
                yield firebase_1.db.runTransaction((transaction) => __awaiter(this, void 0, void 0, function* () {
                    const rewardDoc = yield transaction.get(rewardRef);
                    const accountDoc = yield transaction.get(accountRef);
                    if (!rewardDoc.exists || !accountDoc.exists) {
                        throw new Error('Reward or account not found');
                    }
                    const reward = rewardDoc.data();
                    const account = accountDoc.data();
                    if (account.points < reward.pointsCost) {
                        throw new Error('Insufficient points');
                    }
                    // Generate unique verification code
                    const verificationCode = Math.random().toString(36).substring(2, 8).toUpperCase();
                    // Create redemption record
                    const redemptionRef = this.redemptionsRef.doc();
                    redemptionId = redemptionRef.id;
                    const redemption = {
                        id: redemptionId,
                        userId,
                        rewardId,
                        redemptionDate: new Date(),
                        status: reward.type === loyalty_1.RewardType.GIFT ? loyalty_1.RewardStatus.REDEEMED : loyalty_1.RewardStatus.CLAIMED,
                        verificationCode,
                    };
                    // Update points balance
                    transaction.update(accountRef, {
                        points: account.points - reward.pointsCost,
                        lastUpdated: new Date()
                    });
                    // Save redemption record
                    transaction.set(redemptionRef, redemption);
                }));
                return redemptionId;
            }
            catch (error) {
                console.error('Error redeeming reward:', error);
                throw error;
            }
        });
    }
    verifyAndClaimPhysicalReward(redemptionId, adminId, notes) {
        return __awaiter(this, void 0, void 0, function* () {
            const redemptionRef = this.redemptionsRef.doc(redemptionId);
            try {
                yield firebase_1.db.runTransaction((transaction) => __awaiter(this, void 0, void 0, function* () {
                    const doc = yield transaction.get(redemptionRef);
                    if (!doc.exists) {
                        throw new Error('Redemption not found');
                    }
                    const redemption = doc.data();
                    if (redemption.status !== loyalty_1.RewardStatus.REDEEMED) {
                        throw new Error('Reward already claimed or expired');
                    }
                    transaction.update(redemptionRef, {
                        status: loyalty_1.RewardStatus.CLAIMED,
                        claimedDate: new Date(),
                        claimedByAdminId: adminId,
                        notes
                    });
                }));
                return true;
            }
            catch (error) {
                console.error('Error claiming reward:', error);
                return false;
            }
        });
    }
    getPendingPhysicalRewards() {
        return __awaiter(this, void 0, void 0, function* () {
            const snapshot = yield this.redemptionsRef
                .where('status', '==', loyalty_1.RewardStatus.REDEEMED)
                .get();
            return snapshot.docs.map(doc => doc.data());
        });
    }
    getAvailableRewards(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            const accountDoc = yield this.loyaltyRef.doc(userId).get();
            if (!accountDoc.exists) {
                return [];
            }
            const account = accountDoc.data();
            const rewardsSnapshot = yield this.rewardsRef
                .where('isActive', '==', true)
                .where('pointsCost', '<=', account.points)
                .get();
            return rewardsSnapshot.docs.map(doc => (Object.assign({ id: doc.id }, doc.data())));
        });
    }
    getLoyaltyAccount(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            const doc = yield this.loyaltyRef.doc(userId).get();
            return doc.exists ? doc.data() : null;
        });
    }
}
exports.LoyaltyService = LoyaltyService;
