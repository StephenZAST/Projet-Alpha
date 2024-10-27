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
const delivery_1 = require("../services/delivery");
const router = express_1.default.Router();
const deliveryService = new delivery_1.DeliveryService();
router.get('/timeslots', auth_1.authenticateUser, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { date, zoneId } = req.query;
        const slots = yield deliveryService.getAvailableTimeSlots(new Date(date), zoneId);
        res.json({ slots });
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch time slots' });
    }
}));
router.post('/schedule-pickup', auth_1.authenticateUser, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { orderId, date, timeSlot, address } = req.body;
        const success = yield deliveryService.schedulePickup(orderId, new Date(date), timeSlot, address);
        if (success) {
            res.json({ message: 'Pickup scheduled successfully' });
        }
        else {
            res.status(400).json({ error: 'Failed to schedule pickup' });
        }
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to schedule pickup' });
    }
}));
router.post('/update-location', auth_1.authenticateUser, auth_1.requireDriver, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { orderId, location, status } = req.body;
        const success = yield deliveryService.updateOrderLocation(orderId, location, status);
        if (success) {
            res.json({ message: 'Location updated successfully' });
        }
        else {
            res.status(400).json({ error: 'Failed to update location' });
        }
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to update location' });
    }
}));
exports.default = router;
