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
exports.OrderPricingService = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
class OrderPricingService {
    static calculateItemPrice(item) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                // Récupérer le prix via la table centralisée
                const priceEntry = yield prisma.article_service_prices.findFirst({
                    where: {
                        article_id: item.articleId,
                        service_type_id: item.serviceTypeId,
                        service_id: item.serviceId
                    },
                    include: {
                        service_types: true
                    }
                });
                if (!priceEntry || !priceEntry.is_available)
                    throw new Error('No price available for this article/service type');
                let price = 0;
                if (((_a = priceEntry.service_types) === null || _a === void 0 ? void 0 : _a.pricing_type) === 'PER_WEIGHT' || priceEntry.price_per_kg) {
                    if (!item.weight)
                        throw new Error('Weight required for PER_WEIGHT service');
                    price = Number(priceEntry.price_per_kg) * Number(item.weight);
                }
                else {
                    price = item.isPremium ? Number(priceEntry.premium_price) : Number(priceEntry.base_price);
                    price = price * (item.quantity || 1);
                }
                return price;
            }
            catch (error) {
                console.error('Calculate item price error:', error);
                throw error;
            }
        });
    }
    static calculateTotalPrice(items) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const pricePromises = items.map(item => this.calculateItemPrice(item));
                const prices = yield Promise.all(pricePromises);
                return prices.reduce((total, price) => total + price, 0);
            }
            catch (error) {
                console.error('Calculate total price error:', error);
                throw error;
            }
        });
    }
}
exports.OrderPricingService = OrderPricingService;
