"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RewardStatus = exports.RewardType = exports.LoyaltyTier = void 0;
var LoyaltyTier;
(function (LoyaltyTier) {
    LoyaltyTier["BRONZE"] = "bronze";
    LoyaltyTier["SILVER"] = "silver";
    LoyaltyTier["GOLD"] = "gold";
    LoyaltyTier["PLATINUM"] = "platinum"; // 10001+ points
})(LoyaltyTier || (exports.LoyaltyTier = LoyaltyTier = {}));
var RewardType;
(function (RewardType) {
    RewardType["DISCOUNT_PERCENTAGE"] = "discount_percentage";
    RewardType["DISCOUNT_FIXED"] = "discount_fixed";
    RewardType["FREE_SERVICE"] = "free_service";
    RewardType["GIFT"] = "gift";
})(RewardType || (exports.RewardType = RewardType = {}));
// Add new status for rewards
var RewardStatus;
(function (RewardStatus) {
    RewardStatus["AVAILABLE"] = "available";
    RewardStatus["REDEEMED"] = "redeemed";
    RewardStatus["CLAIMED"] = "claimed";
    RewardStatus["EXPIRED"] = "expired";
})(RewardStatus || (exports.RewardStatus = RewardStatus = {}));
