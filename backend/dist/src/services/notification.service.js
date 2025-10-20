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
exports.NotificationService = void 0;
const client_1 = require("@prisma/client");
const types_1 = require("../models/types");
const prisma = new client_1.PrismaClient();
class NotificationService {
    static sendNotification(userId_1, type_1) {
        return __awaiter(this, arguments, void 0, function* (userId, type, data = {}) {
            try {
                const user = yield prisma.users.findUnique({
                    where: { id: userId }
                });
                if (!user)
                    throw new Error('User not found');
                const rule = yield prisma.notification_rules.findFirst({
                    where: {
                        event_type: type,
                        user_role: user.role || 'CLIENT',
                        is_active: true
                    }
                });
                if (!rule) {
                    console.log(`No notification rule found for type ${type} and role ${user.role || 'CLIENT'}`);
                    return;
                }
                const message = this.buildNotificationMessage(rule.template || '', Object.assign(Object.assign({}, data), { userName: `${user.first_name} ${user.last_name}` }));
                yield this.createDatabaseNotification(userId, type, message, data);
            }
            catch (error) {
                console.error('[NotificationService] Error sending notification:', error);
                throw error;
            }
        });
    }
    static createOrderNotification(userId_1, orderId_1, type_1) {
        return __awaiter(this, arguments, void 0, function* (userId, orderId, type, additionalData = {}) {
            var _a, _b;
            try {
                const order = yield prisma.orders.findUnique({
                    where: { id: orderId },
                    include: {
                        service_types: {
                            select: {
                                name: true
                            }
                        },
                        order_items: {
                            include: {
                                article: {
                                    select: {
                                        name: true
                                    }
                                }
                            }
                        }
                    }
                });
                if (!order)
                    throw new Error('Order not found');
                const notificationData = Object.assign({ orderId, orderStatus: order.status, serviceName: (_a = order.service_types) === null || _a === void 0 ? void 0 : _a.name, totalAmount: order.totalAmount, items: (_b = order.order_items) === null || _b === void 0 ? void 0 : _b.map(item => {
                        var _a, _b;
                        return ({
                            name: (_b = (_a = item.article) === null || _a === void 0 ? void 0 : _a.name) !== null && _b !== void 0 ? _b : 'Unknown Article',
                            quantity: item.quantity
                        });
                    }) }, additionalData);
                yield this.sendNotification(userId, type, notificationData);
                if (order.affiliateCode) {
                    const affiliate = yield prisma.affiliate_profiles.findFirst({
                        where: { affiliate_code: order.affiliateCode }
                    });
                    if (affiliate) {
                        yield this.sendAffiliateNotification(affiliate.userId, orderId, Number(order.totalAmount));
                    }
                }
                if (['READY', 'DELIVERED'].includes(order.status || '')) {
                    yield this.notifyAdmins(types_1.NotificationType.ORDER_STATUS_UPDATED, {
                        orderId,
                        status: order.status,
                        totalAmount: order.totalAmount
                    });
                }
            }
            catch (error) {
                console.error('[NotificationService] Error creating order notification:', error);
                throw error;
            }
        });
    }
    static sendAffiliateNotification(affiliateUserId, orderId, orderAmount) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const affiliate = yield prisma.affiliate_profiles.findFirst({
                    where: { userId: affiliateUserId }
                });
                if (!affiliate)
                    return;
                const commissionAmount = orderAmount * (Number(affiliate.commission_rate) / 100);
                yield this.sendNotification(affiliateUserId, types_1.NotificationType.ORDER_CREATED, {
                    orderId,
                    orderAmount,
                    commissionAmount,
                    currentBalance: Number(affiliate.commission_balance) + commissionAmount
                });
            }
            catch (error) {
                console.error('[NotificationService] Error sending affiliate notification:', error);
                throw error;
            }
        });
    }
    static notifyAdmins(type, data) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const admins = yield prisma.users.findMany({
                    where: {
                        role: {
                            in: ['ADMIN', 'SUPER_ADMIN']
                        }
                    }
                });
                yield Promise.all(admins.map(admin => this.sendNotification(admin.id, type, data)));
            }
            catch (error) {
                console.error('[NotificationService] Error notifying admins:', error);
                throw error;
            }
        });
    }
    static createDatabaseNotification(userId_1, type_1, message_1) {
        return __awaiter(this, arguments, void 0, function* (userId, type, message, data = {}) {
            try {
                yield prisma.notifications.create({
                    data: {
                        userId: userId,
                        type,
                        message,
                        data,
                        read: false,
                        created_at: new Date(),
                        updated_at: new Date()
                    }
                });
            }
            catch (error) {
                console.error('[NotificationService] Error creating database notification:', error);
                throw error;
            }
        });
    }
    static getUserNotifications(userId_1) {
        return __awaiter(this, arguments, void 0, function* (userId, page = 1, limit = 20) {
            try {
                const [notifications, total] = yield prisma.$transaction([
                    prisma.notifications.findMany({
                        where: { userId: userId },
                        orderBy: { created_at: 'desc' },
                        skip: (page - 1) * limit,
                        take: limit
                    }),
                    prisma.notifications.count({
                        where: { userId: userId }
                    })
                ]);
                return {
                    notifications,
                    total,
                    page,
                    totalPages: Math.ceil(total / limit)
                };
            }
            catch (error) {
                console.error('[NotificationService] Error getting user notifications:', error);
                throw error;
            }
        });
    }
    static getUnreadCount(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                return yield prisma.notifications.count({
                    where: {
                        userId: userId,
                        read: false
                    }
                });
            }
            catch (error) {
                console.error('[NotificationService] Error getting unread count:', error);
                throw error;
            }
        });
    }
    static markAsRead(userId, notificationId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield prisma.notifications.updateMany({
                    where: {
                        id: notificationId,
                        userId: userId
                    },
                    data: {
                        read: true,
                        updated_at: new Date()
                    }
                });
            }
            catch (error) {
                console.error('[NotificationService] Error marking notification as read:', error);
                throw error;
            }
        });
    }
    static markAllAsRead(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield prisma.notifications.updateMany({
                    where: {
                        userId: userId,
                        read: false
                    },
                    data: {
                        read: true,
                        updated_at: new Date()
                    }
                });
            }
            catch (error) {
                console.error('[NotificationService] Error marking all notifications as read:', error);
                throw error;
            }
        });
    }
    static deleteNotification(userId, notificationId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield prisma.notifications.deleteMany({
                    where: {
                        id: notificationId,
                        userId: userId
                    }
                });
            }
            catch (error) {
                console.error('[NotificationService] Error deleting notification:', error);
                throw error;
            }
        });
    }
    static getNotificationPreferences(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                return yield prisma.notification_preferences.findFirst({
                    where: { userId: userId }
                });
            }
            catch (error) {
                console.error('[NotificationService] Error getting notification preferences:', error);
                throw error;
            }
        });
    }
    static updateNotificationPreferences(userId, preferences) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const existingPreferences = yield prisma.notification_preferences.findFirst({
                    where: { userId: userId }
                });
                if (existingPreferences) {
                    yield prisma.notification_preferences.update({
                        where: { id: existingPreferences.id },
                        data: Object.assign(Object.assign({}, preferences), { updated_at: new Date() })
                    });
                }
                else {
                    yield prisma.notification_preferences.create({
                        data: Object.assign(Object.assign({ userId: userId }, preferences), { created_at: new Date(), updated_at: new Date() })
                    });
                }
            }
            catch (error) {
                console.error('[NotificationService] Error updating notification preferences:', error);
                throw error;
            }
        });
    }
    static buildNotificationMessage(template, data) {
        return template.replace(/\{(\w+)\}/g, (match, key) => {
            var _a;
            return ((_a = data[key]) === null || _a === void 0 ? void 0 : _a.toString()) || match;
        });
    }
    static createNotification(userIdOrNotification_1, type_1, message_1) {
        return __awaiter(this, arguments, void 0, function* (userIdOrNotification, type, message, data = {}) {
            var _a;
            try {
                if (typeof userIdOrNotification === 'object') {
                    const notification = userIdOrNotification;
                    if (!Object.values(types_1.NotificationType).includes(notification.type)) {
                        throw new Error(`Invalid notification type: ${notification.type}`);
                    }
                    yield prisma.notifications.create({
                        data: {
                            userId: notification.user_id,
                            type: notification.type,
                            message: notification.message,
                            data: notification.data || {},
                            read: (_a = notification.read) !== null && _a !== void 0 ? _a : false,
                            created_at: notification.created_at ? new Date(notification.created_at) : new Date(),
                            updated_at: notification.updated_at ? new Date(notification.updated_at) : new Date()
                        }
                    });
                }
                else {
                    const existing = yield prisma.notifications.findFirst({
                        where: {
                            userId: userIdOrNotification,
                            type: type,
                            message: message,
                            read: false
                        },
                        orderBy: {
                            created_at: 'desc'
                        }
                    });
                    if (existing) {
                        console.log('[NotificationService] Similar notification exists, skipping');
                        return;
                    }
                    yield prisma.notifications.create({
                        data: {
                            userId: userIdOrNotification,
                            type: type,
                            message: message,
                            data,
                            read: false,
                            created_at: new Date(),
                            updated_at: new Date()
                        }
                    });
                }
            }
            catch (error) {
                console.error('[NotificationService] Unexpected error:', error);
                throw error;
            }
        });
    }
    static sendOrderNotification(order) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const rules = yield prisma.notification_rules.findMany({
                    where: {
                        event_type: types_1.NotificationType.ORDER_CREATED,
                        is_active: true
                    }
                });
                if (!(rules === null || rules === void 0 ? void 0 : rules.length)) {
                    console.log('[NotificationService] No active rules found');
                    return;
                }
                const users = yield prisma.users.findMany({
                    where: {
                        role: {
                            in: ['ADMIN', 'SUPER_ADMIN', 'DELIVERY']
                        }
                    }
                });
                if (!(users === null || users === void 0 ? void 0 : users.length))
                    return;
                yield Promise.all(users.map(user => {
                    var _a;
                    return this.sendNotification(user.id, types_1.NotificationType.ORDER_CREATED, {
                        orderId: order.id,
                        total: order.totalAmount,
                        items: ((_a = order.items) === null || _a === void 0 ? void 0 : _a.length) || 0,
                        address: order.address_id
                    });
                }));
            }
            catch (error) {
                console.error('[NotificationService] Error sending order notification:', error);
                throw error;
            }
        });
    }
    static sendRoleBasedNotifications(order, templateData) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const users = yield prisma.users.findMany({
                    where: {
                        role: {
                            in: ['SUPER_ADMIN', 'ADMIN', 'DELIVERY']
                        }
                    }
                });
                if (!(users === null || users === void 0 ? void 0 : users.length))
                    return;
                yield Promise.all(users.map(user => this.sendNotification(user.id, types_1.NotificationType.ORDER_CREATED, {
                    orderId: order.id,
                    title: templateData.title,
                    clientName: templateData.clientName,
                    message: templateData.message,
                    deliveryZone: templateData.deliveryZone,
                    itemCount: templateData.itemCount,
                    amount: user.role === 'DELIVERY' ? undefined : templateData.amount
                })));
            }
            catch (error) {
                console.error('[NotificationService] Error sending role-based notifications:', error);
                throw error;
            }
        });
    }
}
exports.NotificationService = NotificationService;
