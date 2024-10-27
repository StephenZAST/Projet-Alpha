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
exports.updateOrderStatus = exports.getOrdersByUser = exports.createOrder = void 0;
const firebase_1 = require("./firebase");
const order_1 = require("../models/order");
function createOrder(order) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const orderRef = yield firebase_1.db.collection('orders').add(Object.assign(Object.assign({}, order), { creationDate: new Date(), status: order_1.OrderStatus.PENDING }));
            return Object.assign(Object.assign({}, order), { orderId: orderRef.id });
        }
        catch (error) {
            console.error('Error creating order:', error);
            return null;
        }
    });
}
exports.createOrder = createOrder;
function getOrdersByUser(userId) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const ordersSnapshot = yield firebase_1.db.collection('orders')
                .where('userId', '==', userId)
                .orderBy('creationDate', 'desc')
                .get();
            return ordersSnapshot.docs.map(doc => (Object.assign({ orderId: doc.id }, doc.data())));
        }
        catch (error) {
            console.error('Error fetching orders:', error);
            return [];
        }
    });
}
exports.getOrdersByUser = getOrdersByUser;
function updateOrderStatus(orderId, status) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield firebase_1.db.collection('orders').doc(orderId).update({ status });
            return true;
        }
        catch (error) {
            console.error('Error updating order status:', error);
            return false;
        }
    });
}
exports.updateOrderStatus = updateOrderStatus;
