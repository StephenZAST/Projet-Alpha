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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.OrderSharedMethods = void 0;
const prisma_1 = __importDefault(require("../../config/prisma"));
class OrderSharedMethods {
    static getOrderItems(orderId) {
        return __awaiter(this, void 0, void 0, function* () {
            const items = yield prisma_1.default.order_items.findMany({
                where: {
                    orderId: orderId
                },
                include: {
                    article: {
                        include: {
                            article_categories: true
                        }
                    }
                }
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
                article: {
                    id: item.article.id,
                    name: item.article.name,
                    basePrice: Number(item.article.basePrice),
                    premiumPrice: item.article.premiumPrice ? Number(item.article.premiumPrice) : null,
                    categoryId: item.article.categoryId || null,
                    createdAt: item.article.createdAt,
                    updatedAt: item.article.updatedAt,
                    category: item.article.article_categories ? {
                        id: item.article.article_categories.id,
                        name: item.article.article_categories.name,
                        description: item.article.article_categories.description || null
                    } : null
                }
            }));
        });
    }
    static getUserPoints(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            const points = yield prisma_1.default.loyalty_points.findUnique({
                where: {
                    userId: userId
                },
                select: {
                    pointsBalance: true
                }
            });
            return (points === null || points === void 0 ? void 0 : points.pointsBalance) || 0;
        });
    }
    static getOrderWithDetails(orderId) {
        return __awaiter(this, void 0, void 0, function* () {
            const order = yield prisma_1.default.orders.findUnique({
                where: {
                    id: orderId
                },
                include: {
                    user: true,
                    service_types: true,
                    address: true,
                    order_items: {
                        include: {
                            article: {
                                include: {
                                    article_categories: true
                                }
                            }
                        }
                    }
                }
            });
            if (!order) {
                throw new Error('Order not found');
            }
            return Object.assign(Object.assign({}, order), { userId: order.userId, serviceId: order.serviceId, addressId: order.addressId, service_type_id: order.service_type_id, totalAmount: order.totalAmount ? Number(order.totalAmount) : null, isRecurring: order.isRecurring, recurrenceType: order.recurrenceType, nextRecurrenceDate: order.nextRecurrenceDate, collectionDate: order.collectionDate, deliveryDate: order.deliveryDate, affiliateCode: order.affiliateCode, paymentMethod: order.paymentMethod, createdAt: order.createdAt, updatedAt: order.updatedAt, order_items: order.order_items.map(item => ({
                    id: item.id,
                    orderId: item.orderId,
                    articleId: item.articleId,
                    serviceId: item.serviceId,
                    quantity: item.quantity,
                    unitPrice: Number(item.unitPrice),
                    isPremium: item.isPremium || false,
                    createdAt: item.createdAt,
                    updatedAt: item.updatedAt
                })) });
        });
    }
}
exports.OrderSharedMethods = OrderSharedMethods;
