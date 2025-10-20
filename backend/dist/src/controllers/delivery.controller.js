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
exports.DeliveryController = void 0;
const delivery_service_1 = require("../services/delivery.service");
class DeliveryController {
    static getPendingOrders(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield delivery_service_1.DeliveryService.getPendingOrders(userId);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getAssignedOrders(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield delivery_service_1.DeliveryService.getAssignedOrders(userId);
                // 🔍 DEBUG: Log les coordonnées GPS
                console.log('🗺️ [DeliveryController] Commandes assignées avec GPS:');
                result.forEach((order, index) => {
                    var _a, _b, _c, _d;
                    const hasGPS = ((_a = order.address) === null || _a === void 0 ? void 0 : _a.gps_latitude) && ((_b = order.address) === null || _b === void 0 ? void 0 : _b.gps_longitude);
                    console.log(`   [${index + 1}] ${order.id.substring(0, 8)} - GPS: ${hasGPS ? '✅' : '❌'}`);
                    if (hasGPS) {
                        console.log(`       Lat: ${order.address.gps_latitude}, Lng: ${order.address.gps_longitude}`);
                    }
                    else {
                        console.log(`       ⚠️ Pas de GPS pour: ${(_c = order.address) === null || _c === void 0 ? void 0 : _c.city}, ${(_d = order.address) === null || _d === void 0 ? void 0 : _d.street}`);
                    }
                });
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static updateOrderStatus(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                console.log('Request user:', req.user); // Add this line to log the user object
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const orderId = req.params.orderId;
                const { status } = req.body;
                const result = yield delivery_service_1.DeliveryService.updateOrderStatus(orderId, status, userId);
                res.json({ data: result });
            }
            catch (error) {
                console.error('Error updating order status:', error); // Add this line to log the error
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getCOLLECTEDOrders(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield delivery_service_1.DeliveryService.getCOLLECTEDOrders(userId);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getPROCESSINGOrders(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield delivery_service_1.DeliveryService.getPROCESSINGOrders(userId);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getREADYOrders(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield delivery_service_1.DeliveryService.getREADYOrders(userId);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getDELIVERINGOrders(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield delivery_service_1.DeliveryService.getDELIVERINGOrders(userId);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getDELIVEREDOrders(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield delivery_service_1.DeliveryService.getDELIVEREDOrders(userId);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getCANCELLEDOrders(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield delivery_service_1.DeliveryService.getCANCELLEDOrders(userId);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getDraftOrders(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                console.log('📋 [DeliveryController] Récupération des commandes DRAFT pour userId:', userId);
                const result = yield delivery_service_1.DeliveryService.getDraftOrders(userId);
                console.log(`✅ [DeliveryController] ${result.length} commandes DRAFT trouvées`);
                res.json({ data: result });
            }
            catch (error) {
                console.error('❌ [DeliveryController] Erreur getDraftOrders:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
}
exports.DeliveryController = DeliveryController;
