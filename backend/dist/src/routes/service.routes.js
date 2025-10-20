"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const service_controller_1 = require("../controllers/service.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const asyncHandler_1 = require("../utils/asyncHandler");
const router = express_1.default.Router();
// Public routes
router.post('/create', (0, asyncHandler_1.asyncHandler)(service_controller_1.ServiceController.createService));
router.get('/all', (0, asyncHandler_1.asyncHandler)(service_controller_1.ServiceController.getAllServices));
// Admin routes
router.use(auth_middleware_1.authenticateToken);
router.patch('/update/:serviceId', (0, auth_middleware_1.authorizeRoles)(['SUPER_ADMIN', 'ADMIN']), (0, asyncHandler_1.asyncHandler)(service_controller_1.ServiceController.updateService));
router.delete('/delete/:serviceId', (0, auth_middleware_1.authorizeRoles)(['SUPER_ADMIN', 'ADMIN']), (0, asyncHandler_1.asyncHandler)(service_controller_1.ServiceController.deleteService));
router.post('/calculate-price', auth_middleware_1.authenticateToken, (0, asyncHandler_1.asyncHandler)(service_controller_1.ServiceController.getServicePrice));
exports.default = router;
