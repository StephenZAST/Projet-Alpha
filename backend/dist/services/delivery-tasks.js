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
exports.DeliveryTaskService = void 0;
const firebase_1 = require("./firebase");
const delivery_task_1 = require("../models/delivery-task");
class DeliveryTaskService {
    constructor() {
        this.tasksRef = firebase_1.db.collection('delivery_tasks');
        this.ordersRef = firebase_1.db.collection('orders');
    }
    getAvailableTasks(driverId) {
        return __awaiter(this, void 0, void 0, function* () {
            const snapshot = yield this.tasksRef
                .where('status', 'in', ['pending', 'assigned'])
                .where('assignedDriver', '==', driverId)
                .orderBy('scheduledTime.date')
                .orderBy('priority', 'desc')
                .get();
            return snapshot.docs.map(doc => (Object.assign({ id: doc.id }, doc.data())));
        });
    }
    getTasksByArea(center, radiusKm) {
        return __awaiter(this, void 0, void 0, function* () {
            // Implementation using geohashing or Firebase GeoQueries
            // This would show tasks within a specific radius of the driver
            return [];
        });
    }
    updateTaskStatus(taskId, status, driverId, notes) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield this.tasksRef.doc(taskId).update({
                    status,
                    lastUpdated: new Date(),
                    lastUpdatedBy: driverId,
                    notes: notes ? notes : null
                });
                // If task is completed, update order status
                if (status === delivery_task_1.TaskStatus.COMPLETED) {
                    const task = (yield this.tasksRef.doc(taskId).get()).data();
                    yield this.updateOrderStatus(task.orderId, task.type);
                }
                return true;
            }
            catch (error) {
                console.error('Error updating task status:', error);
                return false;
            }
        });
    }
    updateOrderStatus(orderId, taskType) {
        return __awaiter(this, void 0, void 0, function* () {
            const newStatus = taskType === delivery_task_1.TaskType.PICKUP ? 'PICKED_UP' : 'DELIVERED';
            yield this.ordersRef.doc(orderId).update({
                status: newStatus,
                lastUpdated: new Date()
            });
        });
    }
}
exports.DeliveryTaskService = DeliveryTaskService;
