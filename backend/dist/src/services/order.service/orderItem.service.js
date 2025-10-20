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
exports.OrderItemService = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
class OrderItemService {
    static createOrderItem(orderItemData) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            const { orderId, articleId, serviceId, quantity, unitPrice, serviceTypeId, isPremium, weight } = orderItemData;
            // Vérification de l'article
            const article = yield prisma.articles.findFirst({
                where: {
                    id: articleId,
                    isDeleted: false
                }
            });
            if (!article) {
                throw new Error(`Article not found or inactive: ${articleId}`);
            }
            // Récupération du prix via la table centralisée
            const priceEntry = yield prisma.article_service_prices.findFirst({
                where: {
                    article_id: articleId,
                    service_type_id: serviceTypeId
                },
                include: {
                    service_types: true
                }
            });
            if (!priceEntry || !priceEntry.is_available) {
                throw new Error('No price available for this article/service type');
            }
            let calculatedUnitPrice = 0;
            if (((_a = priceEntry.service_types) === null || _a === void 0 ? void 0 : _a.pricing_type) === 'PER_WEIGHT' || priceEntry.price_per_kg) {
                // Cas prix au poids
                if (!weight)
                    throw new Error('Weight required for PER_WEIGHT service');
                calculatedUnitPrice = Number(priceEntry.price_per_kg) * Number(weight);
            }
            else {
                // Cas prix fixe
                calculatedUnitPrice = isPremium ? Number(priceEntry.premium_price) : Number(priceEntry.base_price);
            }
            const orderItem = yield prisma.order_items.create({
                data: {
                    orderId,
                    articleId,
                    serviceId,
                    quantity,
                    unitPrice: new client_1.Prisma.Decimal(calculatedUnitPrice),
                    isPremium: !!isPremium,
                    weight: weight !== undefined ? weight : null,
                    createdAt: new Date(),
                    updatedAt: new Date()
                },
                include: this.itemInclude
            });
            return {
                id: orderItem.id,
                orderId: orderItem.orderId,
                articleId: orderItem.articleId,
                serviceId: orderItem.serviceId,
                quantity: orderItem.quantity,
                unitPrice: Number(orderItem.unitPrice),
                isPremium: orderItem.isPremium || false,
                createdAt: orderItem.createdAt,
                updatedAt: orderItem.updatedAt,
                article: orderItem.article ? {
                    id: orderItem.article.id,
                    categoryId: orderItem.article.categoryId || '',
                    name: orderItem.article.name,
                    description: orderItem.article.description || undefined,
                    basePrice: Number(orderItem.article.basePrice),
                    premiumPrice: Number(orderItem.article.premiumPrice || 0),
                    createdAt: orderItem.article.createdAt || new Date(),
                    updatedAt: orderItem.article.updatedAt || new Date()
                } : undefined
            };
        });
    }
    static getOrderItemById(orderItemId) {
        return __awaiter(this, void 0, void 0, function* () {
            const orderItem = yield prisma.order_items.findUnique({
                where: { id: orderItemId },
                include: this.itemInclude
            });
            if (!orderItem)
                throw new Error('Order item not found');
            return {
                id: orderItem.id,
                orderId: orderItem.orderId,
                articleId: orderItem.articleId,
                serviceId: orderItem.serviceId,
                quantity: orderItem.quantity,
                unitPrice: Number(orderItem.unitPrice),
                isPremium: orderItem.isPremium || false,
                createdAt: orderItem.createdAt,
                updatedAt: orderItem.updatedAt,
                article: orderItem.article ? {
                    id: orderItem.article.id,
                    categoryId: orderItem.article.categoryId || '',
                    name: orderItem.article.name,
                    description: orderItem.article.description || undefined,
                    basePrice: Number(orderItem.article.basePrice),
                    premiumPrice: Number(orderItem.article.premiumPrice || 0),
                    createdAt: orderItem.article.createdAt || new Date(),
                    updatedAt: orderItem.article.updatedAt || new Date()
                } : undefined
            };
        });
    }
    static getAllOrderItems() {
        return __awaiter(this, void 0, void 0, function* () {
            const items = yield prisma.order_items.findMany({
                include: this.itemInclude
            });
            return items.map(item => ({
                id: item.id,
                orderId: item.orderId,
                articleId: item.articleId,
                serviceId: item.serviceId,
                quantity: item.quantity,
                unitPrice: Number(item.unitPrice),
                isPremium: item.isPremium || false,
                createdAt: item.createdAt,
                updatedAt: item.updatedAt,
                article: item.article ? {
                    id: item.article.id,
                    categoryId: item.article.categoryId || '',
                    name: item.article.name,
                    description: item.article.description || undefined,
                    basePrice: Number(item.article.basePrice),
                    premiumPrice: Number(item.article.premiumPrice || 0),
                    createdAt: item.article.createdAt || new Date(),
                    updatedAt: item.article.updatedAt || new Date()
                } : undefined
            }));
        });
    }
    static updateOrderItem(orderItemId, orderItemData) {
        return __awaiter(this, void 0, void 0, function* () {
            const orderItem = yield prisma.order_items.update({
                where: { id: orderItemId },
                data: {
                    quantity: orderItemData.quantity,
                    unitPrice: orderItemData.unitPrice ? new client_1.Prisma.Decimal(orderItemData.unitPrice) : undefined,
                    isPremium: orderItemData.isPremium,
                    updatedAt: new Date()
                },
                include: this.itemInclude
            });
            return {
                id: orderItem.id,
                orderId: orderItem.orderId,
                articleId: orderItem.articleId,
                serviceId: orderItem.serviceId,
                quantity: orderItem.quantity,
                unitPrice: Number(orderItem.unitPrice),
                isPremium: orderItem.isPremium || false,
                createdAt: orderItem.createdAt,
                updatedAt: orderItem.updatedAt,
                article: orderItem.article ? {
                    id: orderItem.article.id,
                    categoryId: orderItem.article.categoryId || '',
                    name: orderItem.article.name,
                    description: orderItem.article.description || undefined,
                    basePrice: Number(orderItem.article.basePrice),
                    premiumPrice: Number(orderItem.article.premiumPrice || 0),
                    createdAt: orderItem.article.createdAt || new Date(),
                    updatedAt: orderItem.article.updatedAt || new Date()
                } : undefined
            };
        });
    }
    static deleteOrderItem(orderItemId) {
        return __awaiter(this, void 0, void 0, function* () {
            yield prisma.order_items.delete({
                where: { id: orderItemId }
            });
        });
    }
    static calculateTotal(orderItems) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            let total = 0;
            for (const item of orderItems) {
                const priceEntry = yield prisma.article_service_prices.findFirst({
                    where: {
                        article_id: item.articleId,
                        service_type_id: item.serviceTypeId
                    },
                    include: {
                        service_types: true
                    }
                });
                if (!priceEntry || !priceEntry.is_available) {
                    throw new Error('No price available for this article/service type');
                }
                let itemTotal = 0;
                if (((_a = priceEntry.service_types) === null || _a === void 0 ? void 0 : _a.pricing_type) === 'PER_WEIGHT' || priceEntry.price_per_kg) {
                    if (!item.weight)
                        throw new Error('Weight required for PER_WEIGHT service');
                    itemTotal = Number(priceEntry.price_per_kg) * Number(item.weight);
                }
                else {
                    itemTotal = (item.isPremium ? Number(priceEntry.premium_price) : Number(priceEntry.base_price)) * (item.quantity || 1);
                }
                total += itemTotal;
            }
            return total;
        });
    }
    static getOrderItemsByOrderId(orderId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const orderItems = yield prisma.order_items.findMany({
                    where: {
                        orderId: orderId
                    },
                    include: {
                        article: true,
                        order: true
                    }
                });
                if (!orderItems.length) {
                    throw new Error('No order items found for this order');
                }
                return orderItems;
            }
            catch (error) {
                console.error('Error getting order items:', error);
                throw error;
            }
        });
    }
}
exports.OrderItemService = OrderItemService;
// Définition de l'include avec les bonnes relations
OrderItemService.itemInclude = {
    article: {
        include: {
            article_categories: true
        }
    }
};
