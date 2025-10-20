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
exports.OrderPaymentService = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
class OrderPaymentService {
    static getCurrentLoyaltyPoints(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const loyaltyPoints = yield prisma.loyalty_points.findUnique({
                    where: {
                        userId: userId
                    },
                    select: {
                        pointsBalance: true
                    }
                });
                return (loyaltyPoints === null || loyaltyPoints === void 0 ? void 0 : loyaltyPoints.pointsBalance) || 0;
            }
            catch (error) {
                console.error('[OrderPaymentService] Error:', error);
                throw error;
            }
        });
    }
    static calculateDiscounts(userId, totalAmount, articleIds, appliedOfferIds) {
        return __awaiter(this, void 0, void 0, function* () {
            let finalAmount = totalAmount;
            const appliedDiscounts = [];
            const availableOffers = yield prisma.offers.findMany({
                where: {
                    id: { in: appliedOfferIds },
                    is_active: true,
                    startDate: { lte: new Date() },
                    endDate: { gte: new Date() }
                },
                include: {
                    offer_articles: {
                        select: {
                            article_id: true
                        }
                    }
                }
            });
            if (!availableOffers.length)
                return { finalAmount, appliedDiscounts };
            const sortedOffers = availableOffers.sort((a, b) => (a.isCumulative === b.isCumulative) ? 0 : a.isCumulative ? 1 : -1);
            for (const offer of sortedOffers) {
                const offerArticleIds = offer.offer_articles.map(a => a.article_id);
                const hasValidArticles = articleIds.some(id => offerArticleIds.includes(id));
                if (!hasValidArticles)
                    continue;
                if (offer.minPurchaseAmount && totalAmount < Number(offer.minPurchaseAmount))
                    continue;
                let discountAmount = 0;
                switch (offer.discountType) {
                    case 'PERCENTAGE':
                        discountAmount = (totalAmount * Number(offer.discountValue)) / 100;
                        break;
                    case 'FIXED_AMOUNT':
                        discountAmount = Number(offer.discountValue);
                        break;
                    case 'POINTS_EXCHANGE':
                        const loyalty = yield prisma.loyalty_points.findUnique({
                            where: { userId: userId },
                            select: { pointsBalance: true }
                        });
                        if (!loyalty || loyalty.pointsBalance < Number(offer.pointsRequired))
                            continue;
                        discountAmount = Number(offer.discountValue);
                        yield prisma.loyalty_points.update({
                            where: { userId: userId },
                            data: {
                                pointsBalance: loyalty.pointsBalance - Number(offer.pointsRequired)
                            }
                        });
                        break;
                }
                if (offer.maxDiscountAmount) {
                    discountAmount = Math.min(discountAmount, Number(offer.maxDiscountAmount));
                }
                finalAmount -= discountAmount;
                appliedDiscounts.push({ offerId: offer.id, discountAmount });
                if (!offer.isCumulative)
                    break;
            }
            return {
                finalAmount: Math.max(finalAmount, 0),
                appliedDiscounts
            };
        });
    }
    static processAffiliateCommission(orderId, affiliateCode, totalAmount) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            const affiliate = yield prisma.affiliate_profiles.findFirst({
                where: {
                    affiliate_code: affiliateCode
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
            if (!affiliate) {
                throw new Error('Affiliate not found');
            }
            if (!affiliate.is_active || affiliate.status !== 'ACTIVE') {
                throw new Error(`Affiliate is not active. Status: ${affiliate.status}, IsActive: ${affiliate.is_active}`);
            }
            try {
                const commissionRate = Number(((_a = affiliate.affiliate_levels) === null || _a === void 0 ? void 0 : _a.commissionRate) || affiliate.commission_rate || 10);
                const commissionAmount = totalAmount * (commissionRate / 100);
                yield prisma.affiliate_profiles.update({
                    where: { id: affiliate.id },
                    data: {
                        commission_balance: new client_1.Prisma.Decimal(Number(affiliate.commission_balance) + commissionAmount),
                        total_earned: new client_1.Prisma.Decimal(Number(affiliate.total_earned) + commissionAmount),
                        total_referrals: (affiliate.total_referrals || 0) + 1
                    }
                });
                yield prisma.commission_transactions.create({
                    data: {
                        affiliate_id: affiliate.id,
                        order_id: orderId,
                        amount: new client_1.Prisma.Decimal(commissionAmount),
                        created_at: new Date(),
                        updated_at: new Date()
                    }
                });
            }
            catch (error) {
                console.error('[OrderService] Error processing affiliate commission:', error);
                throw error;
            }
        });
    }
    static calculateTotal(items) {
        return __awaiter(this, void 0, void 0, function* () {
            const articles = yield prisma.articles.findMany({
                where: {
                    id: { in: items.map(item => item.articleId) }
                }
            });
            if (!articles || articles.length !== items.length) {
                throw new Error('One or more articles not found');
            }
            return items.reduce((total, item) => {
                const article = articles.find(a => a.id === item.articleId);
                return total + (article ? Number(article.basePrice) * item.quantity : 0);
            }, 0);
        });
    }
    static updatePaymentStatus(orderId, paymentStatus, userId) {
        return __awaiter(this, void 0, void 0, function* () {
            yield prisma.orders.update({
                where: {
                    id: orderId
                },
                data: {
                    status: paymentStatus, // Conversion vers le type enum
                    updatedAt: new Date()
                }
            });
        });
    }
}
exports.OrderPaymentService = OrderPaymentService;
