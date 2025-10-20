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
exports.OrderItemController = void 0;
const orderItem_service_1 = require("../services/order.service/orderItem.service");
class OrderItemController {
    static createOrderItem(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const orderItemData = req.body;
                const result = yield orderItem_service_1.OrderItemService.createOrderItem(orderItemData);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getOrderItemById(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const orderItemId = req.params.orderItemId;
                const result = yield orderItem_service_1.OrderItemService.getOrderItemById(orderItemId);
                res.json({ data: result });
            }
            catch (error) {
                res.status(error.message === 'Order item not found' ? 404 : 500)
                    .json({ error: error.message });
            }
        });
    }
    static getAllOrderItems(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const result = yield orderItem_service_1.OrderItemService.getAllOrderItems();
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getOrderItemsByOrderId(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const orderId = req.params.orderId;
                const result = yield orderItem_service_1.OrderItemService.getOrderItemsByOrderId(orderId);
                res.json({
                    success: true,
                    data: result
                });
            }
            catch (error) {
                res.status(error.message.includes('No order items found') ? 404 : 500)
                    .json({
                    success: false,
                    error: error.message
                });
            }
        });
    }
    static updateOrderItem(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const orderItemId = req.params.orderItemId;
                const orderItemData = req.body;
                const result = yield orderItem_service_1.OrderItemService.updateOrderItem(orderItemId, orderItemData);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static deleteOrderItem(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const orderItemId = req.params.orderItemId;
                yield orderItem_service_1.OrderItemService.deleteOrderItem(orderItemId);
                res.json({ message: 'Order item deleted successfully' });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
}
exports.OrderItemController = OrderItemController;
