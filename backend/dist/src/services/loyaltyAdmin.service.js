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
exports.LoyaltyAdminService = void 0;
const client_1 = require("@prisma/client");
const loyalty_service_1 = require("./loyalty.service");
const prisma = new client_1.PrismaClient();
class LoyaltyAdminService {
    // Gestion des points de fidélité
    static getAllLoyaltyPoints(params) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { page, limit, query } = params;
                const skip = (page - 1) * limit;
                const where = {};
                if (query) {
                    where.OR = [
                        {
                            users: {
                                OR: [
                                    { first_name: { contains: query, mode: 'insensitive' } },
                                    { last_name: { contains: query, mode: 'insensitive' } },
                                    { email: { contains: query, mode: 'insensitive' } },
                                ],
                            },
                        },
                    ];
                }
                const [loyaltyPoints, total] = yield Promise.all([
                    prisma.loyalty_points.findMany({
                        where,
                        include: {
                            users: {
                                select: {
                                    id: true,
                                    first_name: true,
                                    last_name: true,
                                    email: true,
                                    phone: true,
                                    created_at: true,
                                },
                            },
                        },
                        skip,
                        take: limit,
                        orderBy: { createdAt: 'desc' },
                    }),
                    prisma.loyalty_points.count({ where }),
                ]);
                return {
                    data: loyaltyPoints.map(this.formatLoyaltyPoints),
                    pagination: {
                        page,
                        limit,
                        total,
                        totalPages: Math.ceil(total / limit),
                    },
                };
            }
            catch (error) {
                console.error('[LoyaltyAdminService] Error getting all loyalty points:', error);
                throw error;
            }
        });
    }
    static getLoyaltyStats() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const [totalUsers, activeUsers, totalPointsDistributed, totalPointsRedeemed, totalRewardsClaimed, pendingClaims,] = yield Promise.all([
                    prisma.loyalty_points.count(),
                    prisma.loyalty_points.count({
                        where: { pointsBalance: { gt: 0 } },
                    }),
                    prisma.point_transactions.aggregate({
                        where: { type: 'EARNED' },
                        _sum: { points: true },
                    }),
                    prisma.point_transactions.aggregate({
                        where: { type: 'SPENT' },
                        _sum: { points: true },
                    }),
                    prisma.reward_claims.count({
                        where: { status: 'APPROVED' },
                    }),
                    prisma.reward_claims.count({
                        where: { status: 'PENDING' },
                    }),
                ]);
                const averagePointsPerUser = totalUsers > 0
                    ? (totalPointsDistributed._sum.points || 0) / totalUsers
                    : 0;
                // Statistiques par source
                const pointsBySource = yield prisma.point_transactions.groupBy({
                    by: ['source'],
                    where: { type: 'EARNED' },
                    _sum: { points: true },
                });
                // Statistiques par type de récompense
                const redemptionsByType = yield prisma.reward_claims.groupBy({
                    by: ['status'],
                    _count: { id: true },
                });
                return {
                    totalUsers,
                    activeUsers,
                    totalPointsDistributed: totalPointsDistributed._sum.points || 0,
                    totalPointsRedeemed: totalPointsRedeemed._sum.points || 0,
                    averagePointsPerUser,
                    totalRewardsClaimed,
                    pendingClaims,
                    pointsBySource: pointsBySource.reduce((acc, item) => {
                        acc[item.source] = item._sum.points || 0;
                        return acc;
                    }, {}),
                    redemptionsByType: redemptionsByType.reduce((acc, item) => {
                        acc[item.status] = item._count.id;
                        return acc;
                    }, {}),
                };
            }
            catch (error) {
                console.error('[LoyaltyAdminService] Error getting loyalty stats:', error);
                throw error;
            }
        });
    }
    static getLoyaltyPointsByUserId(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const loyaltyPoints = yield prisma.loyalty_points.findUnique({
                    where: { userId },
                    include: {
                        users: {
                            select: {
                                id: true,
                                first_name: true,
                                last_name: true,
                                email: true,
                                phone: true,
                                created_at: true,
                            },
                        },
                    },
                });
                if (!loyaltyPoints) {
                    throw new Error('Loyalty points not found for user');
                }
                return this.formatLoyaltyPoints(loyaltyPoints);
            }
            catch (error) {
                console.error('[LoyaltyAdminService] Error getting loyalty points by user ID:', error);
                throw error;
            }
        });
    }
    // Gestion des transactions
    static getPointTransactions(params) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { page, limit, userId, type, source } = params;
                const skip = (page - 1) * limit;
                const where = {};
                if (userId)
                    where.userId = userId;
                if (type)
                    where.type = type;
                if (source)
                    where.source = source;
                const [transactions, total] = yield Promise.all([
                    prisma.point_transactions.findMany({
                        where,
                        include: {
                            users: {
                                select: {
                                    id: true,
                                    first_name: true,
                                    last_name: true,
                                    email: true,
                                },
                            },
                        },
                        skip,
                        take: limit,
                        orderBy: { createdAt: 'desc' },
                    }),
                    prisma.point_transactions.count({ where }),
                ]);
                return {
                    data: transactions.map(this.formatPointTransaction),
                    pagination: {
                        page,
                        limit,
                        total,
                        totalPages: Math.ceil(total / limit),
                    },
                };
            }
            catch (error) {
                console.error('[LoyaltyAdminService] Error getting point transactions:', error);
                throw error;
            }
        });
    }
    static addPointsToUser(userId, points, source, referenceId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                return yield loyalty_service_1.LoyaltyService.earnPoints(userId, points, source, referenceId);
            }
            catch (error) {
                console.error('[LoyaltyAdminService] Error adding points to user:', error);
                throw error;
            }
        });
    }
    static deductPointsFromUser(userId, points, source, referenceId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                return yield loyalty_service_1.LoyaltyService.spendPoints(userId, points, source, referenceId);
            }
            catch (error) {
                console.error('[LoyaltyAdminService] Error deducting points from user:', error);
                throw error;
            }
        });
    }
    static getUserPointHistory(userId, params) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { page, limit } = params;
                const skip = (page - 1) * limit;
                const [transactions, total] = yield Promise.all([
                    prisma.point_transactions.findMany({
                        where: { userId },
                        include: {
                            users: {
                                select: {
                                    id: true,
                                    first_name: true,
                                    last_name: true,
                                    email: true,
                                },
                            },
                        },
                        skip,
                        take: limit,
                        orderBy: { createdAt: 'desc' },
                    }),
                    prisma.point_transactions.count({ where: { userId } }),
                ]);
                return {
                    data: transactions.map(this.formatPointTransaction),
                    pagination: {
                        page,
                        limit,
                        total,
                        totalPages: Math.ceil(total / limit),
                    },
                };
            }
            catch (error) {
                console.error('[LoyaltyAdminService] Error getting user point history:', error);
                throw error;
            }
        });
    }
    // Gestion des récompenses
    static getAllRewards(params) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { page, limit, isActive, type } = params;
                const skip = (page - 1) * limit;
                const where = {};
                // ✅ Utiliser is_active (snake_case) pour Prisma, pas isActive (camelCase)
                if (isActive !== undefined)
                    where.is_active = isActive;
                if (type)
                    where.type = type;
                console.log('🔍 [LoyaltyAdminService] Fetching rewards with params:', { page, limit, isActive, type });
                const [rewards, total] = yield Promise.all([
                    prisma.rewards.findMany({
                        where,
                        skip,
                        take: limit,
                        orderBy: { created_at: 'desc' },
                    }),
                    prisma.rewards.count({ where }),
                ]);
                console.log(`📦 [LoyaltyAdminService] Found ${rewards.length} rewards from DB`);
                // Log des données brutes de la première récompense
                if (rewards.length > 0) {
                    console.log('🔍 [LoyaltyAdminService] First reward RAW data from Prisma:', {
                        id: rewards[0].id,
                        name: rewards[0].name,
                        points_cost: rewards[0].points_cost,
                        discount_value: rewards[0].discount_value,
                        discount_type: rewards[0].discount_type,
                        is_active: rewards[0].is_active,
                        type: rewards[0].type,
                    });
                }
                const formattedRewards = rewards.map(this.formatReward);
                // Log des données formatées de la première récompense
                if (formattedRewards.length > 0) {
                    console.log('✅ [LoyaltyAdminService] First reward FORMATTED data:', {
                        id: formattedRewards[0].id,
                        name: formattedRewards[0].name,
                        pointsCost: formattedRewards[0].pointsCost,
                        discountValue: formattedRewards[0].discountValue,
                        discountType: formattedRewards[0].discountType,
                        isActive: formattedRewards[0].isActive,
                        type: formattedRewards[0].type,
                    });
                }
                return {
                    data: formattedRewards,
                    pagination: {
                        page,
                        limit,
                        total,
                        totalPages: Math.ceil(total / limit),
                    },
                };
            }
            catch (error) {
                console.error('[LoyaltyAdminService] Error getting all rewards:', error);
                throw error;
            }
        });
    }
    static getRewardById(rewardId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const reward = yield prisma.rewards.findUnique({
                    where: { id: rewardId },
                });
                if (!reward) {
                    throw new Error('Reward not found');
                }
                return this.formatReward(reward);
            }
            catch (error) {
                console.error('[LoyaltyAdminService] Error getting reward by ID:', error);
                throw error;
            }
        });
    }
    static createReward(rewardData) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const reward = yield prisma.rewards.create({
                    data: {
                        name: rewardData.name,
                        description: rewardData.description,
                        points_cost: rewardData.pointsCost,
                        type: rewardData.type,
                        discount_value: rewardData.discountValue,
                        discount_type: rewardData.discountType,
                        max_redemptions: rewardData.maxRedemptions,
                        is_active: (_a = rewardData.isActive) !== null && _a !== void 0 ? _a : true,
                    },
                });
                return this.formatReward(reward);
            }
            catch (error) {
                console.error('[LoyaltyAdminService] Error creating reward:', error);
                throw error;
            }
        });
    }
    static updateReward(rewardId, updateData) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const reward = yield prisma.rewards.update({
                    where: { id: rewardId },
                    data: updateData,
                });
                return this.formatReward(reward);
            }
            catch (error) {
                console.error('[LoyaltyAdminService] Error updating reward:', error);
                throw error;
            }
        });
    }
    static deleteReward(rewardId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield prisma.rewards.delete({
                    where: { id: rewardId },
                });
            }
            catch (error) {
                console.error('[LoyaltyAdminService] Error deleting reward:', error);
                throw error;
            }
        });
    }
    // Gestion des demandes de récompenses
    static getRewardClaims(params) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { page, limit, status, userId, rewardId } = params;
                const skip = (page - 1) * limit;
                const where = {};
                if (status)
                    where.status = status;
                if (userId)
                    where.userId = userId;
                if (rewardId)
                    where.rewardId = rewardId;
                const [claims, total] = yield Promise.all([
                    prisma.reward_claims.findMany({
                        where,
                        include: {
                            users: {
                                select: {
                                    id: true,
                                    first_name: true,
                                    last_name: true,
                                    email: true,
                                },
                            },
                            rewards: true,
                        },
                        skip,
                        take: limit,
                        orderBy: { created_at: 'desc' },
                    }),
                    prisma.reward_claims.count({ where }),
                ]);
                return {
                    data: claims.map(this.formatRewardClaim),
                    pagination: {
                        page,
                        limit,
                        total,
                        totalPages: Math.ceil(total / limit),
                    },
                };
            }
            catch (error) {
                console.error('[LoyaltyAdminService] Error getting reward claims:', error);
                throw error;
            }
        });
    }
    static getPendingRewardClaims(params) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                return yield this.getRewardClaims(Object.assign(Object.assign({}, params), { status: 'PENDING' }));
            }
            catch (error) {
                console.error('[LoyaltyAdminService] Error getting pending reward claims:', error);
                throw error;
            }
        });
    }
    static approveRewardClaim(claimId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield prisma.reward_claims.update({
                    where: { id: claimId },
                    data: {
                        status: 'APPROVED',
                        processed_at: new Date(),
                    },
                });
            }
            catch (error) {
                console.error('[LoyaltyAdminService] Error approving reward claim:', error);
                throw error;
            }
        });
    }
    static rejectRewardClaim(claimId, reason) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield prisma.reward_claims.update({
                    where: { id: claimId },
                    data: {
                        status: 'REJECTED',
                        processed_at: new Date(),
                        rejection_reason: reason,
                    },
                });
            }
            catch (error) {
                console.error('[LoyaltyAdminService] Error rejecting reward claim:', error);
                throw error;
            }
        });
    }
    static markRewardClaimAsUsed(claimId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield prisma.reward_claims.update({
                    where: { id: claimId },
                    data: {
                        status: 'USED',
                        used_at: new Date(),
                    },
                });
            }
            catch (error) {
                console.error('[LoyaltyAdminService] Error marking reward claim as used:', error);
                throw error;
            }
        });
    }
    // Méthodes de formatage
    static formatLoyaltyPoints(loyaltyPoints) {
        return {
            id: loyaltyPoints.id,
            userId: loyaltyPoints.userId,
            pointsBalance: loyaltyPoints.pointsBalance || 0,
            totalEarned: loyaltyPoints.totalEarned || 0,
            createdAt: loyaltyPoints.created_at,
            updatedAt: loyaltyPoints.updated_at,
            user: loyaltyPoints.users ? {
                id: loyaltyPoints.users.id,
                firstName: loyaltyPoints.users.first_name,
                lastName: loyaltyPoints.users.last_name,
                email: loyaltyPoints.users.email,
                phone: loyaltyPoints.users.phone,
                createdAt: loyaltyPoints.users.created_at,
            } : null,
        };
    }
    static formatPointTransaction(transaction) {
        return {
            id: transaction.id,
            userId: transaction.userId,
            points: transaction.points,
            type: transaction.type,
            source: transaction.source,
            referenceId: transaction.referenceId,
            createdAt: transaction.created_at,
            updatedAt: transaction.updated_at,
            user: transaction.users ? {
                id: transaction.users.id,
                firstName: transaction.users.first_name,
                lastName: transaction.users.last_name,
                email: transaction.users.email,
            } : null,
        };
    }
    static formatReward(reward) {
        return {
            id: reward.id,
            name: reward.name,
            description: reward.description,
            // ✅ Lire depuis Prisma (snake_case) et transformer en camelCase pour l'API
            pointsCost: reward.points_cost || 0,
            type: reward.type,
            discountValue: reward.discount_value || null,
            discountType: reward.discount_type || null,
            isActive: reward.is_active !== undefined ? reward.is_active : true,
            maxRedemptions: reward.max_redemptions || null,
            currentRedemptions: reward.current_redemptions || 0,
            createdAt: reward.created_at,
            updatedAt: reward.updated_at,
        };
    }
    static formatRewardClaim(claim) {
        return {
            id: claim.id,
            userId: claim.userId,
            rewardId: claim.rewardId,
            pointsUsed: claim.pointsUsed,
            status: claim.status,
            createdAt: claim.created_at,
            processedAt: claim.processedAt,
            user: claim.users ? {
                id: claim.users.id,
                firstName: claim.users.first_name,
                lastName: claim.users.last_name,
                email: claim.users.email,
            } : null,
            reward: claim.rewards ? this.formatReward(claim.rewards) : null,
        };
    }
}
exports.LoyaltyAdminService = LoyaltyAdminService;
