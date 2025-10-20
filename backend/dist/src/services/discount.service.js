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
exports.DiscountService = void 0;
const client_1 = require("@prisma/client");
const discount_types_1 = require("../models/discount.types");
const prisma = new client_1.PrismaClient();
class DiscountService {
    static calculateOrderDiscounts(params) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const discounts = [];
                let remainingTotal = params.subtotal;
                // 1. First Order Discount
                const isFirstOrder = yield this.isFirstOrder(params.userId);
                if (isFirstOrder) {
                    const firstOrderDiscount = this.calculateFirstOrderDiscount(params.subtotal);
                    discounts.push(firstOrderDiscount);
                    remainingTotal -= firstOrderDiscount.amount;
                }
                // 2. Admin Offers
                if (params.appliedOfferIds && params.appliedOfferIds.length > 0) {
                    const offerDiscounts = yield this.calculateAdminOfferDiscounts(params.appliedOfferIds, remainingTotal, discounts.length === 0);
                    discounts.push(...offerDiscounts);
                    remainingTotal -= offerDiscounts.reduce((sum, d) => sum + d.amount, 0);
                }
                // 3. Loyalty Points
                if (params.usePoints && params.usePoints > 0) {
                    const loyaltyDiscount = yield this.calculateLoyaltyDiscount(params.userId, params.usePoints, remainingTotal);
                    if (loyaltyDiscount) {
                        discounts.push(loyaltyDiscount);
                        remainingTotal -= loyaltyDiscount.amount;
                    }
                }
                return {
                    subtotal: params.subtotal,
                    discounts,
                    total: Math.max(0, remainingTotal)
                };
            }
            catch (error) {
                console.error('[DiscountService] Error calculating discounts:', error);
                throw error;
            }
        });
    }
    static isFirstOrder(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            const count = yield prisma.orders.count({
                where: {
                    userId: userId
                }
            });
            return count === 0;
        });
    }
    static calculateFirstOrderDiscount(subtotal) {
        const amount = subtotal * 0.15; // 15% discount
        return {
            type: discount_types_1.DiscountType.FIRST_ORDER,
            amount,
            description: 'Première commande (-15%)'
        };
    }
    static getActiveOffers(offerIds) {
        return __awaiter(this, void 0, void 0, function* () {
            const offers = yield prisma.offers.findMany({
                where: {
                    id: {
                        in: offerIds
                    },
                    is_active: true,
                    startDate: {
                        lte: new Date()
                    },
                    endDate: {
                        gte: new Date()
                    }
                },
                select: {
                    id: true,
                    name: true,
                    discountType: true,
                    discountValue: true,
                    maxDiscountAmount: true,
                    isCumulative: true,
                    minPurchaseAmount: true
                }
            });
            return offers.map(offer => {
                var _a;
                return ({
                    id: offer.id,
                    name: offer.name,
                    type: offer.discountType,
                    value: Number(offer.discountValue),
                    maxValue: offer.maxDiscountAmount ? Number(offer.maxDiscountAmount) : undefined,
                    priority: 1, // Default priority for admin offers
                    isCumulative: (_a = offer.isCumulative) !== null && _a !== void 0 ? _a : false,
                    conditions: {
                        minOrderAmount: offer.minPurchaseAmount ? Number(offer.minPurchaseAmount) : undefined
                    },
                    isActive: true
                });
            });
        });
    }
    static calculateAdminOfferDiscounts(offerIds, remainingTotal, isFirstDiscount) {
        return __awaiter(this, void 0, void 0, function* () {
            const activeOffers = yield this.getActiveOffers(offerIds);
            const discounts = [];
            for (const offer of activeOffers) {
                if (offer.isCumulative || isFirstDiscount || discounts.length === 0) {
                    const amount = Math.min(remainingTotal * (offer.value / 100), offer.maxValue || Infinity);
                    discounts.push({
                        type: discount_types_1.DiscountType.ADMIN_OFFER,
                        amount,
                        description: offer.name
                    });
                }
            }
            return discounts;
        });
    }
    static calculateLoyaltyDiscount(userId, points, remainingTotal) {
        return __awaiter(this, void 0, void 0, function* () {
            const loyalty = yield prisma.loyalty_points.findUnique({
                where: {
                    userId: userId
                },
                select: {
                    pointsBalance: true
                }
            });
            // Check if loyalty exists and has a valid points balance
            if (!loyalty || !loyalty.pointsBalance || loyalty.pointsBalance < points) {
                return null;
            }
            const amount = Math.min(points / 100, remainingTotal); // 1 point = 0.01 currency
            return {
                type: discount_types_1.DiscountType.LOYALTY,
                amount,
                description: `Points fidélité utilisés: ${points}`
            };
        });
    }
}
exports.DiscountService = DiscountService;
