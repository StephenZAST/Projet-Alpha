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
const uuid_1 = require("uuid");
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
class LoyaltyService {
    static earnPoints(userId, points, source, referenceId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const result = yield prisma.$transaction((tx) => __awaiter(this, void 0, void 0, function* () {
                    var _a;
                    const loyaltyPoints = yield tx.loyalty_points.findUnique({
                        where: { userId: userId }
                    });
                    const currentBalance = (loyaltyPoints === null || loyaltyPoints === void 0 ? void 0 : loyaltyPoints.pointsBalance) || 0;
                    const currentTotal = (loyaltyPoints === null || loyaltyPoints === void 0 ? void 0 : loyaltyPoints.totalEarned) || 0;
                    const updatedPoints = yield tx.loyalty_points.update({
                        where: { userId: userId },
                        data: {
                            pointsBalance: { increment: points },
                            totalEarned: { increment: points },
                            updatedAt: new Date()
                        }
                    });
                    yield tx.point_transactions.create({
                        data: {
                            id: (0, uuid_1.v4)(),
                            userId,
                            points,
                            type: 'EARNED',
                            source,
                            referenceId,
                            createdAt: new Date()
                        }
                    });
                    // Mise à jour du solde de points (remplace le trigger SQL)
                    // Suppression de l'update redondant du solde de points
                    // Vérification du solde négatif
                    const checkLoyalty = yield tx.loyalty_points.findUnique({ where: { userId } });
                    if (checkLoyalty && ((_a = checkLoyalty.pointsBalance) !== null && _a !== void 0 ? _a : 0) < 0) {
                        throw new Error('Le solde de points ne peut pas être négatif');
                    }
                    return {
                        id: updatedPoints.id,
                        user_id: updatedPoints.userId || userId, // Assure une valeur non-null
                        pointsBalance: updatedPoints.pointsBalance || 0,
                        totalEarned: updatedPoints.totalEarned || 0,
                        createdAt: updatedPoints.createdAt || new Date(),
                        updatedAt: updatedPoints.updatedAt || new Date()
                    };
                }));
                return result;
            }
            catch (error) {
                console.error('[LoyaltyService] Error earning points:', error);
                throw error;
            }
        });
    }
    static spendPoints(userId, points, source, referenceId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                return yield prisma.$transaction((tx) => __awaiter(this, void 0, void 0, function* () {
                    var _a, _b, _c, _d, _e, _f, _g;
                    const loyaltyPoints = yield tx.loyalty_points.findUnique({
                        where: { userId: userId }
                    });
                    const currentBalance = (_a = loyaltyPoints === null || loyaltyPoints === void 0 ? void 0 : loyaltyPoints.pointsBalance) !== null && _a !== void 0 ? _a : 0;
                    if (!loyaltyPoints || currentBalance < points) {
                        throw new Error('Insufficient points balance');
                    }
                    const updatedPoints = yield tx.loyalty_points.update({
                        where: { userId: userId },
                        data: {
                            pointsBalance: { decrement: points },
                            updatedAt: new Date()
                        }
                    });
                    yield tx.point_transactions.create({
                        data: {
                            id: (0, uuid_1.v4)(),
                            userId,
                            points: -points,
                            type: 'SPENT',
                            source,
                            referenceId,
                            createdAt: new Date()
                        }
                    });
                    // Mise à jour du solde de points (remplace le trigger SQL)
                    // Suppression de l'update redondant du solde de points
                    // Vérification du solde négatif
                    const checkLoyalty = yield tx.loyalty_points.findUnique({ where: { userId } });
                    if (checkLoyalty && ((_b = checkLoyalty.pointsBalance) !== null && _b !== void 0 ? _b : 0) < 0) {
                        throw new Error('Le solde de points ne peut pas être négatif');
                    }
                    // Transformer en type non-null
                    return {
                        id: updatedPoints.id,
                        user_id: (_c = updatedPoints.userId) !== null && _c !== void 0 ? _c : userId,
                        pointsBalance: (_d = updatedPoints.pointsBalance) !== null && _d !== void 0 ? _d : 0,
                        totalEarned: (_e = updatedPoints.totalEarned) !== null && _e !== void 0 ? _e : 0,
                        createdAt: (_f = updatedPoints.createdAt) !== null && _f !== void 0 ? _f : new Date(),
                        updatedAt: (_g = updatedPoints.updatedAt) !== null && _g !== void 0 ? _g : new Date()
                    };
                }));
            }
            catch (error) {
                console.error('[LoyaltyService] Error spending points:', error);
                throw error;
            }
        });
    }
    static getPointsBalance(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const points = yield prisma.loyalty_points.findUnique({
                    where: { userId: userId }
                });
                if (!points)
                    return null;
                return {
                    id: points.id,
                    user_id: points.userId || userId,
                    pointsBalance: points.pointsBalance || 0,
                    totalEarned: points.totalEarned || 0,
                    createdAt: points.createdAt || new Date(),
                    updatedAt: points.updatedAt || new Date()
                };
            }
            catch (error) {
                console.error('[LoyaltyService] Error getting points balance:', error);
                throw error;
            }
        });
    }
    static getCurrentPoints(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const points = yield prisma.loyalty_points.findUnique({
                    where: { userId: userId },
                    select: { pointsBalance: true }
                });
                return (points === null || points === void 0 ? void 0 : points.pointsBalance) || 0;
            }
            catch (error) {
                console.error('[LoyaltyService] Error fetching points:', error);
                throw error;
            }
        });
    }
    static deductPoints(userId, points, referenceId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield prisma.$transaction((tx) => __awaiter(this, void 0, void 0, function* () {
                    var _a, _b;
                    const loyalty = yield tx.loyalty_points.findUnique({
                        where: { userId: userId }
                    });
                    // Vérifier explicitement la valeur de pointsBalance
                    const currentBalance = (_a = loyalty === null || loyalty === void 0 ? void 0 : loyalty.pointsBalance) !== null && _a !== void 0 ? _a : 0;
                    if (!loyalty || currentBalance < points) {
                        throw new Error('Insufficient points');
                    }
                    yield tx.loyalty_points.update({
                        where: { userId: userId },
                        data: {
                            pointsBalance: currentBalance - points,
                            updatedAt: new Date()
                        }
                    });
                    yield tx.point_transactions.create({
                        data: {
                            id: (0, uuid_1.v4)(),
                            userId,
                            points: -points,
                            type: 'SPENT',
                            source: 'ORDER',
                            referenceId,
                            createdAt: new Date()
                        }
                    });
                    // Mise à jour du solde de points (remplace le trigger SQL)
                    yield tx.loyalty_points.update({
                        where: { userId: userId },
                        data: {
                            pointsBalance: { decrement: points },
                            updatedAt: new Date()
                        }
                    });
                    // Vérification du solde négatif
                    const checkLoyalty = yield tx.loyalty_points.findUnique({ where: { userId } });
                    if (checkLoyalty && ((_b = checkLoyalty.pointsBalance) !== null && _b !== void 0 ? _b : 0) < 0) {
                        throw new Error('Le solde de points ne peut pas être négatif');
                    }
                }));
            }
            catch (error) {
                console.error('[LoyaltyService] Error deducting points:', error);
                throw error;
            }
        });
    }
}
exports.LoyaltyService = LoyaltyService;
