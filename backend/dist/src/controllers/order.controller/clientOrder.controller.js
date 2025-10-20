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
exports.ClientOrderController = void 0;
const clientOrderQuery_service_1 = require("../../services/order.service/clientOrderQuery.service");
/**
 * 📱 Contrôleur de commandes pour le CLIENT APP
 *
 * Endpoints dédiés à l'application client mobile avec données enrichies
 */
class ClientOrderController {
    /**
     * GET /api/orders/client/my-orders
     * Récupère les commandes de l'utilisateur connecté avec enrichissement
     */
    static getMyOrdersEnriched(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b, _c, _d, _e;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                console.log('[ClientOrderController] 📱 getMyOrdersEnriched called for userId:', userId);
                if (!userId) {
                    console.log('[ClientOrderController] ❌ No userId found');
                    return res.status(401).json({
                        success: false,
                        error: 'Non authentifié'
                    });
                }
                const orders = yield clientOrderQuery_service_1.ClientOrderQueryService.getUserOrdersEnriched(userId);
                console.log('[ClientOrderController] ✅ Orders fetched:', orders.length);
                console.log('[ClientOrderController] 📊 First order sample:', JSON.stringify({
                    id: (_b = orders[0]) === null || _b === void 0 ? void 0 : _b.id,
                    itemsCount: (_c = orders[0]) === null || _c === void 0 ? void 0 : _c.itemsCount,
                    itemsLength: (_e = (_d = orders[0]) === null || _d === void 0 ? void 0 : _d.items) === null || _e === void 0 ? void 0 : _e.length
                }, null, 2));
                res.json({
                    success: true,
                    data: orders
                });
            }
            catch (error) {
                console.error('[ClientOrderController] ❌ Error in getMyOrdersEnriched:', error);
                res.status(500).json({
                    success: false,
                    error: 'Erreur serveur',
                    message: error.message
                });
            }
        });
    }
    /**
     * GET /api/orders/client/by-id/:orderId
     * Récupère une commande par ID avec enrichissement
     */
    static getOrderByIdEnriched(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const { orderId } = req.params;
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId) {
                    return res.status(401).json({
                        success: false,
                        error: 'Non authentifié'
                    });
                }
                const order = yield clientOrderQuery_service_1.ClientOrderQueryService.getOrderByIdEnriched(orderId);
                // Vérifier que la commande appartient à l'utilisateur
                if (order.userId !== userId) {
                    return res.status(403).json({
                        success: false,
                        error: 'Accès non autorisé'
                    });
                }
                res.json({
                    success: true,
                    data: order
                });
            }
            catch (error) {
                console.error('[ClientOrderController] Error in getOrderByIdEnriched:', error);
                if (error.message === 'Order not found') {
                    return res.status(404).json({
                        success: false,
                        error: 'Commande non trouvée'
                    });
                }
                res.status(500).json({
                    success: false,
                    error: 'Erreur serveur',
                    message: error.message
                });
            }
        });
    }
    /**
     * GET /api/orders/client/recent
     * Récupère les commandes récentes avec enrichissement
     */
    static getRecentOrdersEnriched(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                const limit = parseInt(req.query.limit) || 5;
                if (!userId) {
                    return res.status(401).json({
                        success: false,
                        error: 'Non authentifié'
                    });
                }
                const orders = yield clientOrderQuery_service_1.ClientOrderQueryService.getRecentOrdersEnriched(userId, limit);
                res.json({
                    success: true,
                    data: orders
                });
            }
            catch (error) {
                console.error('[ClientOrderController] Error in getRecentOrdersEnriched:', error);
                res.status(500).json({
                    success: false,
                    error: 'Erreur serveur',
                    message: error.message
                });
            }
        });
    }
}
exports.ClientOrderController = ClientOrderController;
