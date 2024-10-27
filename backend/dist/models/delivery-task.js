"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PriorityLevel = exports.TaskStatus = exports.TaskType = void 0;
var TaskType;
(function (TaskType) {
    TaskType["PICKUP"] = "pickup";
    TaskType["DELIVERY"] = "delivery";
})(TaskType || (exports.TaskType = TaskType = {}));
var TaskStatus;
(function (TaskStatus) {
    TaskStatus["PENDING"] = "pending";
    TaskStatus["ASSIGNED"] = "assigned";
    TaskStatus["IN_PROGRESS"] = "in_progress";
    TaskStatus["COMPLETED"] = "completed";
    TaskStatus["FAILED"] = "failed";
})(TaskStatus || (exports.TaskStatus = TaskStatus = {}));
var PriorityLevel;
(function (PriorityLevel) {
    PriorityLevel["LOW"] = "low";
    PriorityLevel["MEDIUM"] = "medium";
    PriorityLevel["HIGH"] = "high";
    PriorityLevel["URGENT"] = "urgent";
})(PriorityLevel || (exports.PriorityLevel = PriorityLevel = {}));
