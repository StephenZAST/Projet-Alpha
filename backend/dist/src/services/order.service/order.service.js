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
exports.OrderService = void 0;
const client_1 = require("@prisma/client");
const orderCreate_service_1 = require("./orderCreate.service");
const orderQuery_service_1 = require("./orderQuery.service");
const orderStatus_service_1 = require("./orderStatus.service");
const prisma = new client_1.PrismaClient();
class OrderService {
    static createOrder(orderData) {
        return __awaiter(this, void 0, void 0, function* () {
            return orderCreate_service_1.OrderCreateService.createOrder(orderData);
        });
    }
    static getUserOrders(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            return orderQuery_service_1.OrderQueryService.getUserOrders(userId);
        });
    }
    static getOrderDetails(orderId) {
        return __awaiter(this, void 0, void 0, function* () {
            return orderQuery_service_1.OrderQueryService.getOrderDetails(orderId);
        });
    }
    static getRecentOrders() {
        return __awaiter(this, arguments, void 0, function* (limit = 5) {
            return orderQuery_service_1.OrderQueryService.getRecentOrders(limit);
        });
    }
    static getOrdersByStatus(status) {
        return __awaiter(this, void 0, void 0, function* () {
            const orders = yield prisma.orders.groupBy({
                by: ['status'],
                _count: {
                    status: true
                },
                where: status ? { status } : undefined
            });
            return orders.reduce((acc, curr) => {
                if (curr.status) {
                    acc[curr.status] = curr._count.status;
                }
                return acc;
            }, {});
        });
    }
    static updateOrderStatus(orderId, newStatus, userId, userRole) {
        return __awaiter(this, void 0, void 0, function* () {
            return orderStatus_service_1.OrderStatusService.updateOrderStatus(orderId, newStatus, userId, userRole);
        });
    }
    static deleteOrder(orderId, userId, userRole) {
        return __awaiter(this, void 0, void 0, function* () {
            yield prisma.orders.deleteMany({
                where: {
                    id: orderId,
                    OR: [
                        { userId }, // Vérification directe de l'utilisateur
                        ...(userRole === 'ADMIN' || userRole === 'SUPER_ADMIN' ? [{}] : []) // Autorisation basée sur le rôle passé
                    ]
                }
            });
        });
    }
    static calculateTotal(items) {
        return __awaiter(this, void 0, void 0, function* () {
            const itemIds = items.map(item => item.articleId);
            const articles = yield prisma.articles.findMany({
                where: {
                    id: { in: itemIds }
                },
                select: {
                    id: true,
                    basePrice: true
                }
            });
            const articlePrices = new Map(articles.map(article => [article.id, article.basePrice]));
            return items.reduce((total, item) => {
                const price = articlePrices.get(item.articleId);
                if (!price)
                    throw new Error(`Article not found: ${item.articleId}`);
                return total + (Number(price) * item.quantity);
            }, 0);
        });
    }
}
exports.OrderService = OrderService;
