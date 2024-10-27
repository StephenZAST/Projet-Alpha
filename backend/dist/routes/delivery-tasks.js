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
const auth_1 = require("../middleware/auth");
const delivery_tasks_1 = require("../services/delivery-tasks");
const router = express_1.default.Router();
const taskService = new delivery_tasks_1.DeliveryTaskService();
router.get('/tasks', auth_1.authenticateUser, auth_1.requireDriver, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const tasks = yield taskService.getAvailableTasks(req.user.uid);
        res.json({ tasks });
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch tasks' });
    }
}));
router.get('/tasks/area', auth_1.authenticateUser, auth_1.requireDriver, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { latitude, longitude, radius } = req.query;
        const tasks = yield taskService.getTasksByArea({ latitude: Number(latitude), longitude: Number(longitude) }, Number(radius));
        res.json({ tasks });
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch tasks by area' });
    }
}));
router.patch('/tasks/:taskId/status', auth_1.authenticateUser, auth_1.requireDriver, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { status, notes } = req.body;
        const success = yield taskService.updateTaskStatus(req.params.taskId, status, req.user.uid, notes);
        if (success) {
            res.json({ message: 'Task status updated successfully' });
        }
        else {
            res.status(400).json({ error: 'Failed to update task status' });
        }
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to update task status' });
    }
}));
exports.default = router;
