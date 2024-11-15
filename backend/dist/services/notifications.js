"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
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
const firebase_1 = require("./firebase");
const notification_1 = require("../models/notification");
const admin = __importStar(require("firebase-admin"));
class NotificationService {
    constructor() {
        this.notificationsRef = firebase_1.db.collection('notifications');
    }
    createNotification(notification) {
        return __awaiter(this, void 0, void 0, function* () {
            const newNotification = Object.assign(Object.assign({}, notification), { createdAt: admin.firestore.FieldValue.serverTimestamp(), isRead: false });
            const docRef = yield this.notificationsRef.add(newNotification);
            return docRef.id;
        });
    }
    sendOrderStatusNotification(orderId, userId, status, additionalData) {
        return __awaiter(this, void 0, void 0, function* () {
            const notification = {
                type: notification_1.NotificationType.ORDER_STATUS_UPDATE,
                recipientId: userId,
                recipientRole: 'customer', // Fixed type
                title: 'Order Status Update',
                message: `Your order #${orderId} status has been updated to: ${status}`,
                data: Object.assign({ orderId,
                    status }, additionalData),
                isRead: false
            };
            return this.createNotification(notification);
        });
    }
    sendAffiliateCommissionNotification(affiliateId, amount, orderId) {
        return __awaiter(this, void 0, void 0, function* () {
            const notification = {
                type: notification_1.NotificationType.COMMISSION_EARNED,
                recipientId: affiliateId,
                recipientRole: 'affiliate',
                title: 'Commission Earned',
                message: `You've earned a commission of ${amount} from order #${orderId}`,
                data: {
                    orderId,
                    amount
                },
                isRead: false
            };
            return this.createNotification(notification);
        });
    }
    sendLoyaltyPointsReminder(userId, points) {
        return __awaiter(this, void 0, void 0, function* () {
            const notification = {
                type: notification_1.NotificationType.LOYALTY_POINTS_REMINDER,
                recipientId: userId,
                recipientRole: 'customer',
                title: 'Redeem Your Loyalty Points',
                message: `You have ${points} points available to redeem for discounts or gifts!`,
                data: {
                    points
                },
                isRead: false
            };
            return this.createNotification(notification);
        });
    }
    broadcastPromotion(title, message, userRole, expiresAt) {
        return __awaiter(this, void 0, void 0, function* () {
            const batch = firebase_1.db.batch();
            const usersSnapshot = yield firebase_1.db.collection('users')
                .where('role', '==', userRole)
                .get();
            usersSnapshot.docs.forEach(doc => {
                const notificationRef = this.notificationsRef.doc();
                batch.set(notificationRef, {
                    type: notification_1.NotificationType.PROMOTION_AVAILABLE,
                    recipientId: doc.id,
                    recipientRole: userRole,
                    title,
                    message,
                    isRead: false,
                    createdAt: admin.firestore.FieldValue.serverTimestamp(),
                    expiresAt
                });
            });
            return batch.commit();
        });
    }
    markAsRead(notificationId, userId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield this.notificationsRef.doc(notificationId).update({
                    isRead: true,
                    readAt: admin.firestore.FieldValue.serverTimestamp()
                });
                return true;
            }
            catch (error) {
                console.error('Error marking notification as read:', error);
                return false;
            }
        });
    }
    getUserNotifications(userId_1) {
        return __awaiter(this, arguments, void 0, function* (userId, limit = 50) {
            const snapshot = yield this.notificationsRef
                .where('recipientId', '==', userId)
                .orderBy('createdAt', 'desc')
                .limit(limit)
                .get();
            return snapshot.docs.map(doc => (Object.assign({ id: doc.id }, doc.data())));
        });
    }
}
exports.NotificationService = NotificationService;
