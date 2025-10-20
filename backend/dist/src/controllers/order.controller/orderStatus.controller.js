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
exports.OrderStatusController = void 0;
const database_1 = __importDefault(require("../../config/database"));
const types_1 = require("../../models/types");
const services_1 = require("../../services");
const shared_1 = require("./shared");
class OrderStatusController {
    static updateOrderStatus(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                const userRole = (_b = req.user) === null || _b === void 0 ? void 0 : _b.role;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                if (!userRole)
                    return res.status(401).json({ error: 'User role not found' });
                const orderId = req.params.orderId;
                const { status } = req.body;
                // 1. Mettre à jour le statut
                const order = yield this.updateStatus(orderId, status, userId, userRole);
                // 2. Récupérer la commande complète avec les items
                const completeOrder = Object.assign(Object.assign({}, order), { items: yield shared_1.OrderSharedMethods.getOrderItems(orderId) });
                // 3. Si la commande est livrée, traiter les points et commissions
                if (status === 'DELIVERED') {
                    // Confirmer les points de fidélité
                    yield services_1.RewardsService.processOrderPoints(order.userId, completeOrder, 'ORDER');
                    // Confirmer la commission d'affilié si présente
                    if (order.affiliateCode) {
                        yield services_1.RewardsService.processAffiliateCommission(completeOrder);
                    }
                }
                // 4. Envoyer les notifications appropriées
                yield services_1.NotificationService.createOrderNotification(order.userId, orderId, types_1.NotificationType.ORDER_STATUS_UPDATED, { newStatus: status });
                res.json({ data: completeOrder });
            }
            catch (error) {
                console.error('[OrderController] Error updating order status:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
    static updateStatus(orderId, newStatus, userId, userRole) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            // Vérifier les autorisations
            const allowedRoles = ['ADMIN', 'SUPER_ADMIN', 'DELIVERY'];
            if (!allowedRoles.includes(userRole)) {
                throw new Error('Unauthorized to update order status');
            }
            // Vérifier si la commande existe et obtenir son statut actuel
            const order = yield database_1.default.orders.findUnique({
                where: {
                    id: orderId
                }
            });
            if (!order) {
                throw new Error('Order not found');
            }
            // Valider la transition de statut
            const currentStatus = (_a = order.status) !== null && _a !== void 0 ? _a : 'DRAFT';
            if (!this.isValidStatusTransition(currentStatus, newStatus)) {
                throw new Error(`Invalid status transition from ${currentStatus} to ${newStatus}`);
            }
            // Mettre à jour le statut
            const updatedOrder = yield database_1.default.orders.update({
                where: {
                    id: orderId
                },
                data: {
                    status: newStatus,
                    updatedAt: new Date()
                }
            });
            return updatedOrder;
        });
    }
    static isValidStatusTransition(currentStatus, newStatus) {
        var _a;
        const validTransitions = {
            'DRAFT': ['PENDING'],
            'PENDING': ['COLLECTING'],
            'COLLECTING': ['COLLECTED'],
            'COLLECTED': ['PROCESSING'],
            'PROCESSING': ['READY'],
            'READY': ['DELIVERING'],
            'DELIVERING': ['DELIVERED'],
            'DELIVERED': [], // Statut final
            'CANCELLED': [] // Statut final
        };
        return ((_a = validTransitions[currentStatus]) === null || _a === void 0 ? void 0 : _a.includes(newStatus)) || false;
    }
    static deleteOrder(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const { orderId } = req.params;
                const userRole = (_a = req.user) === null || _a === void 0 ? void 0 : _a.role;
                if (userRole !== 'ADMIN' && userRole !== 'SUPER_ADMIN') {
                    return res.status(403).json({ error: 'Unauthorized' });
                }
                yield database_1.default.orders.delete({
                    where: {
                        id: orderId
                    }
                });
                res.json({ message: 'Order deleted successfully' });
            }
            catch (error) {
                console.error('[OrderController] Error deleting order:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
}
exports.OrderStatusController = OrderStatusController;
