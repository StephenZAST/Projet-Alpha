"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const subscription_controller_1 = require("../controllers/subscription.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const asyncHandler_1 = require("../utils/asyncHandler");
const subscription_middleware_1 = require("../middleware/subscription.middleware");
const router = express_1.default.Router();
// Routes protégées
router.use(auth_middleware_1.authenticateToken);
// Routes client
router.get('/active', (0, asyncHandler_1.asyncHandler)(subscription_controller_1.SubscriptionController.getActiveSubscription));
router.post('/subscribe', subscription_middleware_1.validateSubscription, (0, asyncHandler_1.asyncHandler)(subscription_controller_1.SubscriptionController.subscribeToPlan));
router.post('/:subscriptionId/cancel', (0, asyncHandler_1.asyncHandler)(subscription_controller_1.SubscriptionController.cancelSubscription));
// Routes admin
router.get('/plans', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)(subscription_controller_1.SubscriptionController.getAllPlans));
router.get('/plans/:planId/users', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)(subscription_controller_1.SubscriptionController.getPlanSubscribersWithNames));
router.post('/plans', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)(subscription_controller_1.SubscriptionController.createPlan));
exports.default = router;
