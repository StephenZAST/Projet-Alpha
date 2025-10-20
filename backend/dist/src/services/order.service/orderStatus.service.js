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
exports.OrderStatusService = void 0;
const client_1 = require("@prisma/client");
const types_1 = require("../../models/types");
const notification_service_1 = require("../notification.service");
const prisma = new client_1.PrismaClient();
class OrderStatusService {
    static validateStatusTransition(currentStatus, newStatus) {
        const validNextStatuses = this.validStatusTransitions[currentStatus];
        return validNextStatuses.includes(newStatus);
    }
    static updateOrderStatus(orderId, newStatus, userId, userRole) {
        return __awaiter(this, void 0, void 0, function* () {
            console.log(`Attempting to update order ${orderId} to status ${newStatus}`);
            try {
                // 1. Vérifier si la commande existe
                const order = yield prisma.orders.findUnique({
                    where: { id: orderId },
                    include: {
                        order_items: {
                            include: {
                                article: true
                            }
                        }
                    }
                });
                if (!order) {
                    throw new Error('Order not found');
                }
                // 2. Vérifier les autorisations
                const allowedRoles = ['ADMIN', 'SUPER_ADMIN', 'DELIVERY'];
                if (!allowedRoles.includes(userRole)) {
                    throw new Error('Unauthorized to update order status');
                }
                // 3. Valider la transition de statut
                if (!this.validateStatusTransition(order.status, newStatus)) {
                    throw new Error(`Invalid status transition from ${order.status} to ${newStatus}`);
                }
                // Conversion du type payment_method_enum vers PaymentMethod
                const convertPaymentMethod = (method) => {
                    switch (method) {
                        case 'CASH':
                            return types_1.PaymentMethod.CASH;
                        case 'ORANGE_MONEY':
                            return types_1.PaymentMethod.ORANGE_MONEY;
                        default:
                            return types_1.PaymentMethod.CASH;
                    }
                };
                // 4. Mettre à jour le statut
                const updatedOrder = yield prisma.orders.update({
                    where: { id: orderId },
                    data: {
                        status: newStatus,
                        updatedAt: new Date()
                    },
                    include: {
                        order_items: {
                            include: {
                                article: true
                            }
                        },
                        service_types: true
                    }
                });
                // 5. Si le statut est "DELIVERED", mettre à jour les statistiques
                if (newStatus === 'DELIVERED' && order.status !== 'DELIVERED') {
                    yield this.handleDeliveredStatus(orderId, order.userId);
                }
                // 6. Notifier le client
                yield notification_service_1.NotificationService.createOrderNotification(order.userId, orderId, types_1.NotificationType.ORDER_STATUS_UPDATED, { newStatus });
                // 7. Formater la réponse selon l'interface Order
                return {
                    id: updatedOrder.id,
                    userId: updatedOrder.userId,
                    service_id: updatedOrder.serviceId || '',
                    address_id: updatedOrder.addressId || '',
                    status: updatedOrder.status,
                    isRecurring: updatedOrder.isRecurring || false,
                    recurrenceType: updatedOrder.recurrenceType || 'NONE',
                    totalAmount: Number(updatedOrder.totalAmount || 0),
                    collectionDate: updatedOrder.collectionDate || undefined,
                    deliveryDate: updatedOrder.deliveryDate || undefined,
                    createdAt: updatedOrder.createdAt || new Date(),
                    updatedAt: updatedOrder.updatedAt || new Date(),
                    service_type_id: updatedOrder.service_type_id,
                    paymentStatus: updatedOrder.status,
                    paymentMethod: convertPaymentMethod(updatedOrder.paymentMethod),
                    affiliateCode: updatedOrder.affiliateCode || undefined,
                    items: updatedOrder.order_items.map(item => ({
                        id: item.id,
                        orderId: item.orderId,
                        articleId: item.articleId,
                        serviceId: item.serviceId,
                        quantity: item.quantity,
                        unitPrice: Number(item.unitPrice),
                        isPremium: item.isPremium || false,
                        article: item.article ? {
                            id: item.article.id,
                            categoryId: item.article.categoryId || '',
                            name: item.article.name,
                            description: item.article.description || undefined,
                            basePrice: Number(item.article.basePrice),
                            premiumPrice: Number(item.article.premiumPrice || 0),
                            createdAt: item.article.createdAt || new Date(),
                            updatedAt: item.article.updatedAt || new Date()
                        } : undefined,
                        createdAt: item.createdAt,
                        updatedAt: item.updatedAt
                    }))
                };
            }
            catch (error) {
                console.error('Error updating order status:', error);
                throw error;
            }
        });
    }
    static handleDeliveredStatus(orderId, userId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield prisma.orders.update({
                    where: { id: orderId },
                    data: {
                        updatedAt: new Date()
                    }
                });
            }
            catch (error) {
                console.error('Error updating delivery statistics:', error);
            }
        });
    }
    static deleteOrder(orderId, userId, userRole) {
        return __awaiter(this, void 0, void 0, function* () {
            const order = yield prisma.orders.findUnique({
                where: { id: orderId }
            });
            if (!order) {
                throw new Error('Order not found');
            }
            if (order.userId !== userId && !['ADMIN', 'SUPER_ADMIN'].includes(userRole)) {
                throw new Error('Unauthorized to delete order');
            }
            yield prisma.orders.delete({
                where: { id: orderId }
            });
        });
    }
}
exports.OrderStatusService = OrderStatusService;
OrderStatusService.validStatusTransitions = {
    'DRAFT': ['PENDING'],
    'PENDING': ['COLLECTING'],
    'COLLECTING': ['COLLECTED'],
    'COLLECTED': ['PROCESSING'],
    'PROCESSING': ['READY'],
    'READY': ['DELIVERING'],
    'DELIVERING': ['DELIVERED'],
    'DELIVERED': [],
    'CANCELLED': []
};
