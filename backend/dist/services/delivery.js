"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
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
exports.DeliveryService = void 0;
const firebase_1 = require("./firebase");
const notifications_1 = require("./notifications");
class DeliveryService {
    constructor() {
        this.ordersRef = firebase_1.db.collection('orders');
        this.driversRef = firebase_1.db.collection('drivers');
        this.routesRef = firebase_1.db.collection('routes');
        this.notificationService = new notifications_1.NotificationService();
    }
    getAvailableTimeSlots(date, zoneId) {
        return __awaiter(this, void 0, void 0, function* () {
            // Implementation for fetching available time slots based on date and zone
            const slots = yield this.routesRef
                .where('date', '==', date)
                .where('zoneId', '==', zoneId)
                .get();
            // Process and return available time slots
            return slots.docs.map(doc => doc.data());
        });
    }
    schedulePickup(orderId, date, timeSlot, address) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield this.ordersRef.doc(orderId).update({
                    'pickup.scheduledDate': date,
                    'pickup.timeSlot': timeSlot,
                    'pickup.address': address,
                    status: 'PICKUP_SCHEDULED',
                    updatedAt: new Date()
                });
                // Assign driver and optimize route
                yield this.optimizeRoute(orderId, date, timeSlot);
                // Send notification to customer
                // Implementation here
                return true;
            }
            catch (error) {
                console.error('Error scheduling pickup:', error);
                return false;
            }
        });
    }
    optimizeRoute(orderId, date, timeSlot) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // Implementation for route optimization
                // This would typically involve:
                // 1. Getting all deliveries in the same time slot
                // 2. Calculating optimal route using external service (Google Maps, etc.)
                // 3. Assigning drivers based on availability and location
                // 4. Updating route information
                return null; // Placeholder
            }
            catch (error) {
                console.error('Error optimizing route:', error);
                return null;
            }
        });
    }
    updateOrderLocation(orderId, location, status) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const trackingEvent = {
                    status,
                    timestamp: new Date(),
                    location,
                    updatedBy: 'system'
                };
                yield this.ordersRef.doc(orderId).update({
                    'tracking.currentLocation': location,
                    'tracking.currentStatus': status,
                    'tracking.lastUpdated': new Date(),
                    'tracking.events': admin.firestore.FieldValue.arrayUnion(trackingEvent)
                });
                return true;
            }
            catch (error) {
                console.error('Error updating order location:', error);
                return false;
            }
        });
    }
}
exports.DeliveryService = DeliveryService;
const admin = __importStar(require("firebase-admin"));
