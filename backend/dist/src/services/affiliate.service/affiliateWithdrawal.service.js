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
exports.AffiliateWithdrawalService = void 0;
const client_1 = require("@prisma/client");
const notification_service_1 = require("../notification.service");
const types_1 = require("../../models/types");
const prisma = new client_1.PrismaClient();
class AffiliateWithdrawalService {
    static requestWithdrawal(affiliateId, amount) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                return yield prisma.$transaction((tx) => __awaiter(this, void 0, void 0, function* () {
                    // Vérifier le solde
                    const affiliate = yield tx.affiliate_profiles.findUnique({
                        where: { id: affiliateId },
                        select: {
                            commission_balance: true,
                            userId: true
                        }
                    });
                    if (!affiliate || Number(affiliate.commission_balance) < amount) {
                        throw new Error('Insufficient balance');
                    }
                    // Créer la transaction
                    const withdrawal = yield tx.commission_transactions.create({
                        data: {
                            affiliate_id: affiliateId,
                            amount: new client_1.Prisma.Decimal(amount),
                            order_id: null,
                            created_at: new Date(),
                            updated_at: new Date()
                        }
                    });
                    // Mettre à jour le solde
                    yield tx.affiliate_profiles.update({
                        where: { id: affiliateId },
                        data: {
                            commission_balance: {
                                decrement: new client_1.Prisma.Decimal(amount)
                            },
                            updated_at: new Date()
                        }
                    });
                    return withdrawal;
                }));
            }
            catch (error) {
                console.error('[AffiliateWithdrawalService] Request withdrawal error:', error);
                throw error;
            }
        });
    }
    static getWithdrawals(pagination, withdrawalStatus) {
        return __awaiter(this, void 0, void 0, function* () {
            const { page = 1, limit = 10 } = pagination;
            const skip = (page - 1) * limit;
            try {
                const [withdrawals, total] = yield Promise.all([
                    prisma.commission_transactions.findMany({
                        skip,
                        take: limit,
                        where: {
                            order_id: null, // transactions de retrait uniquement
                        },
                        include: {
                            affiliate_profiles: {
                                include: {
                                    users: {
                                        select: {
                                            id: true,
                                            email: true,
                                            first_name: true,
                                            last_name: true,
                                            phone: true
                                        }
                                    }
                                }
                            }
                        },
                        orderBy: {
                            created_at: 'desc'
                        }
                    }),
                    prisma.commission_transactions.count({
                        where: {
                            order_id: null
                        }
                    })
                ]);
                return {
                    data: withdrawals.map(w => this.formatWithdrawalResponse(w)),
                    pagination: {
                        total,
                        currentPage: page,
                        limit,
                        totalPages: Math.ceil(total / limit)
                    }
                };
            }
            catch (error) {
                console.error('[AffiliateWithdrawalService] Get withdrawals error:', error);
                throw error;
            }
        });
    }
    static formatWithdrawalResponse(withdrawal) {
        return {
            id: withdrawal.id,
            amount: Number(withdrawal.amount || 0),
            created_at: withdrawal.created_at,
            updated_at: withdrawal.updated_at,
            status: withdrawal.status || 'PENDING',
            affiliate_profile: withdrawal.affiliate_profiles ? {
                id: withdrawal.affiliate_profiles.id,
                user: withdrawal.affiliate_profiles.users ? {
                    id: withdrawal.affiliate_profiles.users.id,
                    email: withdrawal.affiliate_profiles.users.email,
                    first_name: withdrawal.affiliate_profiles.users.first_name,
                    last_name: withdrawal.affiliate_profiles.users.last_name,
                    phone: withdrawal.affiliate_profiles.users.phone
                } : undefined
            } : undefined
        };
    }
    static rejectWithdrawal(withdrawalId, reason) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                return yield prisma.$transaction((tx) => __awaiter(this, void 0, void 0, function* () {
                    var _a;
                    const withdrawal = yield tx.commission_transactions.findFirst({
                        where: {
                            id: withdrawalId,
                            order_id: null,
                            status: 'PENDING'
                        },
                        include: {
                            affiliate_profiles: true
                        }
                    });
                    if (!withdrawal) {
                        throw new Error('Withdrawal not found or not in pending status');
                    }
                    const refundAmount = Math.abs(Number(withdrawal.amount || 0));
                    // Mettre à jour le statut
                    yield tx.commission_transactions.update({
                        where: { id: withdrawalId },
                        data: {
                            status: 'REJECTED',
                            updated_at: new Date()
                        }
                    });
                    // Rembourser le montant
                    if (!withdrawal.affiliate_id) {
                        throw new Error('Invalid affiliate ID');
                    }
                    yield tx.affiliate_profiles.update({
                        where: { id: withdrawal.affiliate_id },
                        data: {
                            commission_balance: {
                                increment: refundAmount
                            },
                            updated_at: new Date()
                        }
                    });
                    // Notification
                    if ((_a = withdrawal.affiliate_profiles) === null || _a === void 0 ? void 0 : _a.userId) {
                        yield notification_service_1.NotificationService.sendNotification(withdrawal.affiliate_profiles.userId, types_1.NotificationType.WITHDRAWAL_REJECTED, {
                            amount: refundAmount,
                            reason
                        });
                    }
                    return { message: 'Withdrawal rejected successfully' };
                }));
            }
            catch (error) {
                console.error('[AffiliateWithdrawalService] Reject withdrawal error:', error);
                throw error;
            }
        });
    }
    static approveWithdrawal(withdrawalId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                return yield prisma.$transaction((tx) => __awaiter(this, void 0, void 0, function* () {
                    var _a;
                    const withdrawal = yield tx.commission_transactions.findFirst({
                        where: {
                            id: withdrawalId,
                            order_id: null,
                            status: 'PENDING'
                        },
                        include: {
                            affiliate_profiles: true
                        }
                    });
                    if (!withdrawal) {
                        throw new Error('Withdrawal not found or not in pending status');
                    }
                    yield tx.commission_transactions.update({
                        where: { id: withdrawalId },
                        data: {
                            status: 'APPROVED',
                            updated_at: new Date()
                        }
                    });
                    // Notification
                    if ((_a = withdrawal.affiliate_profiles) === null || _a === void 0 ? void 0 : _a.userId) {
                        yield notification_service_1.NotificationService.sendNotification(withdrawal.affiliate_profiles.userId, types_1.NotificationType.WITHDRAWAL_PROCESSED, {
                            amount: Math.abs(Number(withdrawal.amount || 0)),
                            transactionId: withdrawal.id
                        });
                    }
                    return { message: 'Withdrawal approved successfully' };
                }));
            }
            catch (error) {
                console.error('[AffiliateWithdrawalService] Approve withdrawal error:', error);
                throw error;
            }
        });
    }
    static getPendingWithdrawals(pagination) {
        return __awaiter(this, void 0, void 0, function* () {
            const { page = 1, limit = 10 } = pagination;
            const skip = (page - 1) * limit;
            try {
                const [withdrawals, total] = yield Promise.all([
                    prisma.commission_transactions.findMany({
                        skip,
                        take: limit,
                        where: {
                            order_id: null,
                            status: 'PENDING'
                        },
                        include: {
                            affiliate_profiles: {
                                include: {
                                    users: {
                                        select: {
                                            id: true,
                                            email: true,
                                            first_name: true,
                                            last_name: true,
                                            phone: true
                                        }
                                    }
                                }
                            }
                        },
                        orderBy: {
                            created_at: 'desc'
                        }
                    }),
                    prisma.commission_transactions.count({
                        where: {
                            order_id: null,
                            status: 'PENDING'
                        }
                    })
                ]);
                return {
                    data: withdrawals.map(w => this.formatWithdrawalResponse(w)),
                    pagination: {
                        total,
                        currentPage: page,
                        limit,
                        totalPages: Math.ceil(total / limit)
                    }
                };
            }
            catch (error) {
                console.error('[AffiliateWithdrawalService] Get pending withdrawals error:', error);
                throw error;
            }
        });
    }
}
exports.AffiliateWithdrawalService = AffiliateWithdrawalService;
