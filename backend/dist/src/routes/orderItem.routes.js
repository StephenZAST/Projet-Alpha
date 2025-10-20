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
const orderItem_controller_1 = require("../controllers/orderItem.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const asyncHandler_1 = require("../utils/asyncHandler");
const router = express_1.default.Router();
// Protection des routes avec authentification
router.use(auth_middleware_1.authenticateToken);
// Routes admin
router.post('/', (0, auth_middleware_1.authorizeRoles)(['ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield orderItem_controller_1.OrderItemController.createOrderItem(req, res);
})));
router.get('/:orderItemId', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield orderItem_controller_1.OrderItemController.getOrderItemById(req, res);
})));
router.get('/order/:orderId', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield orderItem_controller_1.OrderItemController.getOrderItemsByOrderId(req, res);
})));
router.get('/', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield orderItem_controller_1.OrderItemController.getAllOrderItems(req, res);
})));
router.patch('/:orderItemId', (0, auth_middleware_1.authorizeRoles)(['ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield orderItem_controller_1.OrderItemController.updateOrderItem(req, res);
})));
router.delete('/:orderItemId', (0, auth_middleware_1.authorizeRoles)(['ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield orderItem_controller_1.OrderItemController.deleteOrderItem(req, res);
})));
exports.default = router;
