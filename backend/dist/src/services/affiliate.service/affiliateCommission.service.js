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
exports.AffiliateCommissionService = void 0;
const client_1 = require("@prisma/client");
const notification_service_1 = require("../notification.service");
const types_1 = require("../../models/types");
const prisma = new client_1.PrismaClient();
const MIN_WITHDRAWAL_AMOUNT = 5000; // 5000 FCFA minimum
class AffiliateCommissionService {
    static getCommissions(affiliateId_1) {
        return __awaiter(this, arguments, void 0, function* (affiliateId, page = 1, limit = 10) {
            try {
                const skip = (page - 1) * limit;
                const [commissions, total] = yield Promise.all([
                    prisma.commission_transactions.findMany({
                        skip,
                        take: limit,
                        where: {
                            affiliate_id: affiliateId
                        },
                        include: {
                            orders: true,
                            affiliate_profiles: true
                        },
                        orderBy: {
                            created_at: 'desc'
                        }
                    }),
                    prisma.commission_transactions.count({
                        where: {
                            affiliate_id: affiliateId
                        }
                    })
                ]);
                return {
                    data: commissions.map(commission => ({
                        id: commission.id,
                        orderId: commission.order_id,
                        amount: Number(commission.amount || 0), // Utiliser commission.amount au lieu de orders.totalAmount
                        status: commission.status,
                        createdAt: commission.created_at || new Date(),
                        order: commission.orders ? {
                            id: commission.orders.id,
                            totalAmount: Number(commission.orders.totalAmount || 0),
                            createdAt: commission.orders.createdAt
                        } : null
                    })),
                    pagination: {
                        total,
                        currentPage: page,
                        limit,
                        totalPages: Math.ceil(total / limit)
                    }
                };
            }
            catch (error) {
                console.error('[AffiliateCommissionService] Get commissions error:', error);
                throw error;
            }
        });
    }
    static requestWithdrawal(affiliateId, amount) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                if (amount < MIN_WITHDRAWAL_AMOUNT) {
                    throw new Error(`Le montant minimum de retrait est de ${MIN_WITHDRAWAL_AMOUNT} FCFA`);
                }
                const affiliate = yield prisma.affiliate_profiles.findUnique({
                    where: { id: affiliateId },
                    include: {
                        users: true
                    }
                });
                if (!affiliate) {
                    throw new Error('Profil affilié non trouvé');
                }
                if (!affiliate.is_active || affiliate.status !== 'ACTIVE') {
                    throw new Error('Le compte affilié n\'est pas actif');
                }
                if (Number(affiliate.commission_balance) < amount) {
                    throw new Error('Solde insuffisant');
                }
                // Utilisation d'une transaction Prisma
                const transaction = yield prisma.$transaction((prisma) => __awaiter(this, void 0, void 0, function* () {
                    const [withdrawal, updatedProfile] = yield Promise.all([
                        prisma.commission_transactions.create({
                            data: {
                                affiliate_id: affiliateId,
                                order_id: null, // Temporaire - à revoir dans le schéma
                                amount: amount,
                                created_at: new Date(),
                                updated_at: new Date()
                            }
                        }),
                        prisma.affiliate_profiles.update({
                            where: { id: affiliateId },
                            data: {
                                commission_balance: {
                                    decrement: new client_1.Prisma.Decimal(amount)
                                },
                                updated_at: new Date()
                            }
                        })
                    ]);
                    return { withdrawal, updatedProfile };
                }));
                // Utilisation du type de notification correct
                yield notification_service_1.NotificationService.sendNotification(affiliate.userId, types_1.NotificationType.WITHDRAWAL_REQUESTED, {
                    amount,
                    transactionId: transaction.withdrawal.id,
                    status: 'PENDING',
                    message: `Votre demande de retrait de ${amount} FCFA a été enregistrée et est en attente de validation.`
                });
                return transaction.withdrawal;
            }
            catch (error) {
                console.error('[AffiliateCommissionService] Request withdrawal error:', error);
                throw error;
            }
        });
    }
    static calculateCommissionRate(totalReferrals) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const level = yield prisma.affiliate_levels.findFirst({
                    where: {
                        minEarnings: {
                            lte: totalReferrals
                        }
                    },
                    orderBy: {
                        minEarnings: 'desc'
                    }
                });
                return Number((level === null || level === void 0 ? void 0 : level.commissionRate) || 10);
            }
            catch (error) {
                console.error('[AffiliateCommissionService] Calculate commission rate error:', error);
                throw error;
            }
        });
    }
    static processNewCommission(orderId, orderAmount, affiliateCode) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const affiliate = yield prisma.affiliate_profiles.findFirst({
                    where: {
                        affiliate_code: affiliateCode,
                        is_active: true,
                        status: 'ACTIVE'
                    }
                });
                if (!affiliate) {
                    throw new Error('Active affiliate not found');
                }
                const commissionRate = yield this.calculateCommissionRate(affiliate.total_referrals || 0);
                const commissionAmount = orderAmount * (commissionRate / 100);
                yield prisma.$transaction([
                    prisma.affiliate_profiles.update({
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
                    }),
                    prisma.commission_transactions.create({
                        data: {
                            affiliate_id: affiliate.id,
                            order_id: orderId,
                            amount: commissionAmount,
                            created_at: new Date(),
                            updated_at: new Date()
                        }
                    })
                ]);
                return true;
            }
            catch (error) {
                console.error('[AffiliateCommissionService] Process commission error:', error);
                throw error;
            }
        });
    }
    static resetMonthlyEarnings() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield prisma.affiliate_profiles.updateMany({
                    data: {
                        monthly_earnings: new client_1.Prisma.Decimal(0),
                        updated_at: new Date()
                    }
                });
            }
            catch (error) {
                console.error('[AffiliateCommissionService] Reset monthly earnings error:', error);
                throw error;
            }
        });
    }
}
exports.AffiliateCommissionService = AffiliateCommissionService;
