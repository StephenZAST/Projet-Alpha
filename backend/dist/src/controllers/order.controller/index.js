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
exports.OrderSharedMethods = exports.FlashOrderController = exports.OrderStatusController = exports.OrderQueryController = exports.OrderCreateController = exports.OrderController = void 0;
const orderCreate_controller_1 = require("./orderCreate.controller");
Object.defineProperty(exports, "OrderCreateController", { enumerable: true, get: function () { return orderCreate_controller_1.OrderCreateController; } });
const orderQuery_controller_1 = require("./orderQuery.controller");
Object.defineProperty(exports, "OrderQueryController", { enumerable: true, get: function () { return orderQuery_controller_1.OrderQueryController; } });
const orderStatus_controller_1 = require("./orderStatus.controller");
Object.defineProperty(exports, "OrderStatusController", { enumerable: true, get: function () { return orderStatus_controller_1.OrderStatusController; } });
const flashOrder_controller_1 = require("./flashOrder.controller");
Object.defineProperty(exports, "FlashOrderController", { enumerable: true, get: function () { return flashOrder_controller_1.FlashOrderController; } });
const shared_1 = require("./shared");
Object.defineProperty(exports, "OrderSharedMethods", { enumerable: true, get: function () { return shared_1.OrderSharedMethods; } });
const orderUpdate_controller_1 = require("./orderUpdate.controller");
const orderMap_controller_1 = require("./orderMap.controller");
class OrderController {
    // Méthodes de création
    static createOrder(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            yield orderCreate_controller_1.OrderCreateController.createOrder(req, res);
        });
    }
    static calculateTotal(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            yield orderCreate_controller_1.OrderCreateController.calculateTotal(req, res);
        });
    }
    // Méthodes de lecture
    static getOrderDetails(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            yield orderQuery_controller_1.OrderQueryController.getOrderDetails(req, res);
        });
    }
    // Export de la recherche par ID
    static getOrderById(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            yield orderQuery_controller_1.OrderQueryController.getOrderById(req, res);
        });
    }
    static getUserOrders(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            yield orderQuery_controller_1.OrderQueryController.getUserOrders(req, res);
        });
    }
    static getRecentOrders(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            yield orderQuery_controller_1.OrderQueryController.getRecentOrders(req, res);
        });
    }
    static getAllOrders(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            yield orderQuery_controller_1.OrderQueryController.getAllOrders(req, res);
        });
    }
    static getOrdersByStatus(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            yield orderQuery_controller_1.OrderQueryController.getOrdersByStatus(req, res);
        });
    }
    static generateInvoice(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            yield orderQuery_controller_1.OrderQueryController.generateInvoice(req, res);
        });
    }
    // Méthodes de gestion des statuts
    static updateOrderStatus(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            yield orderStatus_controller_1.OrderStatusController.updateOrderStatus(req, res);
        });
    }
    static deleteOrder(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            yield orderStatus_controller_1.OrderStatusController.deleteOrder(req, res);
        });
    }
    // PATCH flexible d'une commande
    static patchOrderFields(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            yield orderUpdate_controller_1.OrderUpdateController.patchOrderFields(req, res);
        });
    }
    // Méthodes de commande flash
    static createFlashOrder(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            yield flashOrder_controller_1.FlashOrderController.createFlashOrder(req, res);
        });
    }
    static getAllPendingOrders(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            yield flashOrder_controller_1.FlashOrderController.getAllPendingOrders(req, res);
        });
    }
    static completeFlashOrder(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            yield flashOrder_controller_1.FlashOrderController.completeFlashOrder(req, res);
        });
    }
    // Méthodes de carte
    static getOrdersForMap(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            yield orderMap_controller_1.OrderMapController.getOrdersForMap(req, res);
        });
    }
    static getOrdersGeoStats(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            yield orderMap_controller_1.OrderMapController.getOrdersGeoStats(req, res);
        });
    }
}
exports.OrderController = OrderController;
// Méthodes partagées
OrderController.getOrderItems = shared_1.OrderSharedMethods.getOrderItems;
OrderController.getUserPoints = shared_1.OrderSharedMethods.getUserPoints;
