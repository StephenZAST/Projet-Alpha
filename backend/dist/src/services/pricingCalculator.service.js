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
exports.PricingCalculatorService = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
class PricingCalculatorService {
    static calculateOrderPrice(items, weight) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                if (weight && !(yield this.validateWeightRange(weight))) {
                    throw new Error('Invalid weight range');
                }
                yield this.validateServiceCompatibility(items);
                let total = 0;
                const breakdown = [];
                if (weight) {
                    const weightCost = yield this.calculateWeightBasedPrice(weight);
                    total += weightCost.cost;
                    breakdown.push(weightCost);
                }
                // S'assurer que chaque item a bien serviceTypeId
                const itemsWithType = items.map(item => (Object.assign(Object.assign({}, item), { serviceTypeId: item.serviceTypeId || '' // à adapter si valeur par défaut nécessaire
                 })));
                const itemCosts = yield this.calculateItemBasedPrices(itemsWithType);
                total += itemCosts.total;
                breakdown.push(...itemCosts.breakdown);
                return { total, breakdown };
            }
            catch (error) {
                console.error('[PricingCalculatorService] Calculate price error:', error);
                throw error;
            }
        });
    }
    static validateWeightRange(weight) {
        return __awaiter(this, void 0, void 0, function* () {
            const pricing = yield prisma.weight_based_pricing.findFirst({
                where: {
                    AND: [
                        { min_weight: { lte: new client_1.Prisma.Decimal(weight) } },
                        { max_weight: { gte: new client_1.Prisma.Decimal(weight) } }
                    ]
                }
            });
            return !!pricing;
        });
    }
    static validateServiceCompatibility(items) {
        return __awaiter(this, void 0, void 0, function* () {
            for (const item of items) {
                // Vérifie la compatibilité via la table centralisée article_service_prices
                const exists = yield prisma.article_service_prices.findFirst({
                    where: {
                        article_id: item.articleId,
                        service_id: item.serviceId,
                        is_available: true
                    }
                });
                if (!exists) {
                    throw new Error(`Service ${item.serviceId} is not compatible with article ${item.articleId}`);
                }
            }
        });
    }
    static calculateWeightBasedPrice(weight) {
        return __awaiter(this, void 0, void 0, function* () {
            const pricing = yield prisma.weight_based_pricing.findFirst({
                where: {
                    AND: [
                        { min_weight: { lte: new client_1.Prisma.Decimal(weight) } },
                        { max_weight: { gte: new client_1.Prisma.Decimal(weight) } }
                    ]
                }
            });
            const cost = pricing ? Number(pricing.price_per_kg) * weight : 0;
            return {
                type: 'WEIGHT',
                weight,
                pricePerKg: pricing ? Number(pricing.price_per_kg) : 0,
                cost
            };
        });
    }
    static calculateItemBasedPrices(items) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            let total = 0;
            const breakdown = [];
            for (const item of items) {
                const price = yield prisma.article_service_prices.findFirst({
                    where: {
                        article_id: item.articleId,
                        service_id: item.serviceId,
                        service_type_id: item.serviceTypeId,
                        is_available: true
                    }
                });
                if (price) {
                    const basePrice = item.isPremium ?
                        Number((_a = price.premium_price) !== null && _a !== void 0 ? _a : price.base_price) :
                        Number(price.base_price);
                    const itemCost = basePrice * item.quantity;
                    total += itemCost;
                    breakdown.push(Object.assign(Object.assign({ type: 'ITEM' }, item), { basePrice, cost: itemCost }));
                }
            }
            return { total, breakdown };
        });
    }
}
exports.PricingCalculatorService = PricingCalculatorService;
