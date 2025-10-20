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
const express_1 = __importDefault(require("express"));
const notification_controller_1 = require("../controllers/notification.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const pagination_1 = require("../utils/pagination");
const asyncHandler_1 = require("../utils/asyncHandler");
const router = express_1.default.Router();
// Protection de toutes les routes avec authentification
router.use(auth_middleware_1.authenticateToken);
// Routes pour la gestion des notifications
router.get('/', (req, res, next) => {
    req.query = (0, pagination_1.validatePaginationParams)(req.query);
    next();
}, (0, asyncHandler_1.asyncHandler)((req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    yield notification_controller_1.NotificationController.getNotifications(req, res);
})));
router.get('/unread', (0, asyncHandler_1.asyncHandler)((req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    yield notification_controller_1.NotificationController.getUnreadCount(req, res);
})));
// Actions sur les notifications individuelles
router.patch('/:notificationId/read', (0, asyncHandler_1.asyncHandler)((req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    yield notification_controller_1.NotificationController.markAsRead(req, res);
})));
router.delete('/:notificationId', (0, asyncHandler_1.asyncHandler)((req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    yield notification_controller_1.NotificationController.deleteNotification(req, res);
})));
// Actions groupées
router.post('/mark-all-read', (0, asyncHandler_1.asyncHandler)((req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    yield notification_controller_1.NotificationController.markAllAsRead(req, res);
})));
// Préférences de notification
router.get('/preferences', (0, asyncHandler_1.asyncHandler)((req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    yield notification_controller_1.NotificationController.getPreferences(req, res);
})));
router.put('/preferences', (0, asyncHandler_1.asyncHandler)((req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    yield notification_controller_1.NotificationController.updatePreferences(req, res);
})));
exports.default = router;
