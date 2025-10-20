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
const delivery_controller_1 = require("../controllers/delivery.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const asyncHandler_1 = require("../utils/asyncHandler");
const router = express_1.default.Router();
// Protection des routes avec authentification
router.use(auth_middleware_1.authenticateToken);
// Routes livreur
router.get('/pending-orders', (0, auth_middleware_1.authorizeRoles)(['DELIVERY', 'ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield delivery_controller_1.DeliveryController.getPendingOrders(req, res);
})));
router.get('/assigned-orders', (0, auth_middleware_1.authorizeRoles)(['DELIVERY', 'ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield delivery_controller_1.DeliveryController.getAssignedOrders(req, res);
})));
router.patch('/:orderId/status', (0, auth_middleware_1.authorizeRoles)(['DELIVERY', 'SUPER_ADMIN', 'ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield delivery_controller_1.DeliveryController.updateOrderStatus(req, res);
})));
router.get('/collected-orders', (0, auth_middleware_1.authorizeRoles)(['DELIVERY', 'ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield delivery_controller_1.DeliveryController.getCOLLECTEDOrders(req, res);
})));
router.get('/processing-orders', (0, auth_middleware_1.authorizeRoles)(['DELIVERY', 'ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield delivery_controller_1.DeliveryController.getPROCESSINGOrders(req, res);
})));
router.get('/ready-orders', (0, auth_middleware_1.authorizeRoles)(['DELIVERY', 'ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield delivery_controller_1.DeliveryController.getREADYOrders(req, res);
})));
router.get('/delivering-orders', (0, auth_middleware_1.authorizeRoles)(['DELIVERY', 'ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield delivery_controller_1.DeliveryController.getDELIVERINGOrders(req, res);
})));
router.get('/delivered-orders', (0, auth_middleware_1.authorizeRoles)(['DELIVERY', 'ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield delivery_controller_1.DeliveryController.getDELIVEREDOrders(req, res);
})));
router.get('/cancelled-orders', (0, auth_middleware_1.authorizeRoles)(['DELIVERY', 'ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield delivery_controller_1.DeliveryController.getCANCELLEDOrders(req, res);
})));
router.get('/draft-orders', (0, auth_middleware_1.authorizeRoles)(['DELIVERY', 'ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield delivery_controller_1.DeliveryController.getDraftOrders(req, res);
})));
exports.default = router;
