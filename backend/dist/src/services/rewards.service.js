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
exports.RewardsService = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
class RewardsService {
    static processOrderPoints(userId_1, order_1) {
        return __awaiter(this, arguments, void 0, function* (userId, order, source = 'ORDER') {
            try {
                const pointsToAward = Math.floor(Number(order.totalAmount) * this.DEFAULT_POINTS_PER_AMOUNT);
                yield prisma.$transaction((tx) => __awaiter(this, void 0, void 0, function* () {
                    // Vérifier et mettre à jour le profil de fidélité
                    const loyalty = yield tx.loyalty_points.upsert({
                        where: { userId: userId },
                        update: {
                            pointsBalance: {
                                increment: pointsToAward
                            },
                            totalEarned: {
                                increment: pointsToAward
                            },
                            updatedAt: new Date()
                        },
                        create: {
                            userId: userId,
                            pointsBalance: pointsToAward,
                            totalEarned: pointsToAward,
                            createdAt: new Date(),
                            updatedAt: new Date()
                        }
                    });
                    // Créer la transaction de points
                    yield tx.point_transactions.create({
                        data: {
                            userId,
                            points: pointsToAward,
                            type: 'EARNED',
                            source,
                            referenceId: order.id,
                            createdAt: new Date()
                            // Ne pas inclure updated_at
                        }
                    });
                }));
            }
            catch (error) {
                console.error('[RewardsService] Error processing order points:', error);
                throw error;
            }
        });
    }
    static processReferralPoints(referrerId, referredUserId, pointsAmount) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield prisma.$transaction((tx) => __awaiter(this, void 0, void 0, function* () {
                    // Mettre à jour les points du parrain
                    yield tx.loyalty_points.upsert({
                        where: { userId: referrerId },
                        update: {
                            pointsBalance: {
                                increment: pointsAmount
                            },
                            totalEarned: {
                                increment: pointsAmount
                            },
                            updatedAt: new Date()
                        },
                        create: {
                            userId: referrerId,
                            pointsBalance: pointsAmount,
                            totalEarned: pointsAmount,
                            createdAt: new Date(),
                            updatedAt: new Date()
                        }
                    });
                    // Enregistrer la transaction
                    yield tx.point_transactions.create({
                        data: {
                            userId: referrerId,
                            points: pointsAmount,
                            type: 'EARNED',
                            source: 'REFERRAL',
                            referenceId: referredUserId,
                            createdAt: new Date()
                            // Ne pas inclure updated_at
                        }
                    });
                }));
            }
            catch (error) {
                console.error('[RewardsService] Error processing referral points:', error);
                throw error;
            }
        });
    }
    static calculateLoyaltyDiscount(points, total) {
        return __awaiter(this, void 0, void 0, function* () {
            const conversionRate = Number(process.env.POINTS_TO_DISCOUNT_RATE || '0.1');
            const maxDiscountPercentage = Number(process.env.MAX_POINTS_DISCOUNT_PERCENTAGE || '30');
            let discountAmount = points * conversionRate;
            const maxDiscount = (total * maxDiscountPercentage) / 100;
            return Math.min(discountAmount, maxDiscount);
        });
    }
    static processAffiliateCommission(order) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b;
            try {
                if (!order.affiliateCode)
                    return;
                const affiliate = yield prisma.affiliate_profiles.findFirst({
                    where: {
                        affiliate_code: order.affiliateCode,
                        is_active: true,
                        status: 'ACTIVE'
                    },
                    include: {
                        affiliate_levels: true,
                        users: {
                            select: {
                                email: true,
                                first_name: true,
                                last_name: true
                            }
                        }
                    }
                });
                if (!affiliate)
                    throw new Error('No active affiliate found with this code');
                const commissionRate = (_b = (_a = affiliate.affiliate_levels) === null || _a === void 0 ? void 0 : _a.commissionRate) !== null && _b !== void 0 ? _b : this.DEFAULT_COMMISSION_RATE;
                const commissionAmount = Number(order.totalAmount) * Number(commissionRate);
                yield prisma.$transaction((tx) => __awaiter(this, void 0, void 0, function* () {
                    // Mettre à jour le solde de commission
                    yield tx.affiliate_profiles.update({
                        where: { id: affiliate.id },
                        data: {
                            commission_balance: {
                                increment: commissionAmount
                            },
                            total_earned: {
                                increment: commissionAmount
                            },
                            monthly_earnings: {
                                increment: commissionAmount
                            },
                            total_referrals: {
                                increment: 1
                            },
                            updated_at: new Date()
                        }
                    });
                    // Correction de la création de la transaction de commission
                    yield tx.commission_transactions.create({
                        data: {
                            affiliate_id: affiliate.id,
                            order_id: order.id,
                            created_at: new Date(),
                            amount: commissionAmount
                        }
                    });
                    // Process parent commissions récursivement
                    if (affiliate.parent_affiliate_id) {
                        yield this.processParentCommissions(affiliate.parent_affiliate_id, order.id, commissionAmount, 1);
                    }
                }));
            }
            catch (error) {
                console.error('[RewardsService] Error processing affiliate commission:', error);
                throw error;
            }
        });
    }
    static processParentCommissions(parentAffiliateId_1, orderId_1, baseCommissionAmount_1, level_1) {
        return __awaiter(this, arguments, void 0, function* (parentAffiliateId, orderId, baseCommissionAmount, level, maxLevels = 3) {
            if (!parentAffiliateId || level > maxLevels)
                return;
            try {
                const parentCommissionAmount = baseCommissionAmount * this.PARENT_COMMISSION_RATE;
                yield prisma.$transaction((tx) => __awaiter(this, void 0, void 0, function* () {
                    // Mettre à jour le solde du parent
                    yield tx.affiliate_profiles.update({
                        where: { id: parentAffiliateId },
                        data: {
                            commission_balance: {
                                increment: parentCommissionAmount
                            },
                            total_earned: {
                                increment: parentCommissionAmount
                            },
                            monthly_earnings: {
                                increment: parentCommissionAmount
                            },
                            updated_at: new Date()
                        }
                    });
                    // Créer la transaction en supprimant le champ status non supporté
                    yield tx.commission_transactions.create({
                        data: {
                            affiliate_id: parentAffiliateId,
                            order_id: orderId,
                            created_at: new Date(),
                            amount: parentCommissionAmount
                        }
                    });
                    // Récursion pour le niveau parent suivant
                    const parentAffiliate = yield tx.affiliate_profiles.findUnique({
                        where: { id: parentAffiliateId },
                        select: { parent_affiliate_id: true }
                    });
                    if (parentAffiliate === null || parentAffiliate === void 0 ? void 0 : parentAffiliate.parent_affiliate_id) {
                        yield this.processParentCommissions(parentAffiliate.parent_affiliate_id, orderId, parentCommissionAmount, level + 1, maxLevels);
                    }
                }));
            }
            catch (error) {
                console.error('[RewardsService] Error processing parent commissions:', error);
                throw error;
            }
        });
    }
    static convertPointsToDiscount(userId, points, orderId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield prisma.$transaction((tx) => __awaiter(this, void 0, void 0, function* () {
                    var _a;
                    const loyalty = yield tx.loyalty_points.findUnique({
                        where: { userId: userId }
                    });
                    // Vérification plus stricte des points
                    const currentPoints = (_a = loyalty === null || loyalty === void 0 ? void 0 : loyalty.pointsBalance) !== null && _a !== void 0 ? _a : 0;
                    if (!loyalty || currentPoints < points) {
                        throw new Error('Insufficient points balance');
                    }
                    yield tx.loyalty_points.update({
                        where: { userId: userId },
                        data: {
                            pointsBalance: Math.max(0, currentPoints - points), // Éviter les valeurs négatives
                            updatedAt: new Date()
                        }
                    });
                    yield tx.point_transactions.create({
                        data: {
                            userId,
                            points: -points,
                            type: 'SPENT',
                            source: 'ORDER',
                            referenceId: orderId,
                            createdAt: new Date()
                            // Ne pas inclure updated_at
                        }
                    });
                }));
                return points;
            }
            catch (error) {
                console.error('[RewardsService] Error converting points to discount:', error);
                throw error;
            }
        });
    }
}
exports.RewardsService = RewardsService;
RewardsService.DEFAULT_POINTS_PER_AMOUNT = 1;
RewardsService.DEFAULT_COMMISSION_RATE = 0.1;
RewardsService.PARENT_COMMISSION_RATE = 0.1;
