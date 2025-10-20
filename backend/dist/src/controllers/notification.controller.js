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
exports.NotificationController = void 0;
const notification_service_1 = require("../services/notification.service");
class NotificationController {
    static getNotifications(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const page = parseInt(req.query.page) || 1;
                const limit = parseInt(req.query.limit) || 10;
                const result = yield notification_service_1.NotificationService.getUserNotifications(userId, page, limit);
                res.json(result);
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getUnreadCount(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const count = yield notification_service_1.NotificationService.getUnreadCount(userId);
                res.json({ count });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static markAsRead(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                const { notificationId } = req.params;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                yield notification_service_1.NotificationService.markAsRead(userId, notificationId);
                res.json({ success: true });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static markAllAsRead(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                yield notification_service_1.NotificationService.markAllAsRead(userId);
                res.json({ success: true });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static deleteNotification(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                const { notificationId } = req.params;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                yield notification_service_1.NotificationService.deleteNotification(userId, notificationId);
                res.json({ success: true });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getPreferences(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const preferences = yield notification_service_1.NotificationService.getNotificationPreferences(userId);
                res.json({ data: preferences });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static updatePreferences(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const preferences = yield notification_service_1.NotificationService.updateNotificationPreferences(userId, req.body);
                res.json({ data: preferences });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
}
exports.NotificationController = NotificationController;
